import XCTest
@testable import NodeGraphSwift_ios

class _DeferredTestNode: AbstractNode {
    var processed: (() -> Void)? = nil
    var cancelled: (() -> Void)? = nil
    var aInput: NodeInput!
    var bInput: NodeInput!
    var aOutput: NodeOutput!
    var deferred: Bool
    
    override var useDeferredProcessing: Bool {
        return deferred
    }
    
    override init() {
        deferred = false
        aOutput = NodeOutput(withKey: "a")
        
        super.init()
        
        aInput = NodeInput(withKey: "a", forNode: self)
        bInput = NodeInput(withKey: "b", forNode: self)
        
        inputs = Set<NodeInput>([aInput, bInput])
        outputs = Set<NodeOutput>([aOutput])
    }
    
    override func doProcess(_ completion: @escaping () -> Void) {
        completion()
        if let processedCallback = processed {
            processedCallback()
        }
    }
    
    override func cancel() {
        super.cancel()
        if let cancelledCallback = cancelled {
            cancelledCallback()
        }
    }
}

class AbstractNodeTests: XCTestCase {

    var abstractNode: AbstractNode!
    var deferredTestNode: _DeferredTestNode!
    var performanceInterations: NSInteger!
    
    override func setUp() {
        abstractNode = AbstractNode()
        abstractNode.inputs.insert(NodeInput(withKey: nil, forNode: abstractNode))
        abstractNode.outputs.insert(NodeOutput())
        
        deferredTestNode = _DeferredTestNode()
        
        performanceInterations = 8000
    }
    
    // MARK: Input to Output
    func test_inputTriggersProcessingToOutputConnections() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        let value = NSNumber(42)
        
        abstractNode.outputs.randomElement()?.addConnection(nodeInput: connection)
        abstractNode.inputs.randomElement()?.value = value
        
        XCTAssertEqual(connection.value, value)
    }
    
    func test_cancelOperationForwardsCancelRecursivly() {
        var cancelCalled = false
        deferredTestNode.cancelled = {
            cancelCalled = true
        }
        
        abstractNode.outputs.randomElement()?.addConnection(nodeInput: deferredTestNode.aInput)
        abstractNode.cancel()
        XCTAssertTrue(cancelCalled)
    }
    
    // MARK: Cancelling
    func test_cancelOperationInCircularGraphsDoesNotTriggerInfiniteLoop() {
        var cancelCallCount = 0
        deferredTestNode.cancelled = {
            cancelCallCount += 1
        }
        
        abstractNode.outputs.randomElement()?.addConnection(nodeInput: deferredTestNode.aInput)
        deferredTestNode.aOutput.addConnection(nodeInput: abstractNode.inputs.randomElement()!)
        abstractNode.cancel()
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    // MARK: Deferred processing
    func test_directProcessingPerformance() {
        let measureExpectation = expectation(description: "Measure time")

        measure(block: {[weak self] (completion) in
            guard let strongSelf = self else {
                print("FAILED")
                return
            }
            strongSelf.abstractNode.process()
            completion()
        }, iterations: performanceInterations!) {[weak self] (time) in
            guard let strongSelf = self else {
                print("FAILED")
                return
            }
            let totalTime = time * 1000
            let averageTime = totalTime / Double(strongSelf.performanceInterations!)

            print("\nDeferred processing performance Total (ms): \(String(describing: totalTime)) \nAverage (ms): \(String(describing: averageTime)) \nIterations: \(String(describing: strongSelf.performanceInterations))\n")
            measureExpectation.fulfill()
        }

        waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func test_deferredProcessingPerformance() {
        let measureExpectation = expectation(description: "measure time")
        measure(block: {[weak self] (completion) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.deferredTestNode.processed = {
                completion()
            }
            strongSelf.deferredTestNode.process()
        }, iterations: 8000) {[weak self] (time) in
            guard let strongSelf = self else {
                print("FAILED")
                return
            }
            let totalTime = time * 1000
            let averageTime = totalTime / Double(strongSelf.performanceInterations!)

            print("\nDeferred processing performance Total (ms): \(String(describing: totalTime)) \nAverage (ms): \(String(describing: averageTime)) \nIterations: \(String(describing: strongSelf.performanceInterations))\n")
            measureExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    // MARK: Helpers
    func measure(block: @escaping ((_ completion: @escaping () -> Void ) -> Void),
                 iterations: NSInteger,
                 completion: @escaping (_ time: TimeInterval) -> Void) {
        let start = Date().timeIntervalSince1970
        var testTime: TimeInterval = 0.0
        
        let dispatchGroup = DispatchGroup()
        for _ in 0...iterations {
            dispatchGroup.enter()
            block() {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            testTime = Date().timeIntervalSince1970 - start
            completion(testTime)
        }
    }
}
