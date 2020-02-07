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
        deferred = true
        aOutput = NodeOutput(withKey: "a")
        
        super.init()
        
        aInput = NodeInput(withKey: "a", forNode: self)
        bInput = NodeInput(withKey: "b", forNode: self)
        
        inputs = Set<NodeInput>([aInput, bInput])
        outputs = Set<NodeOutput>([aOutput])
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func doProcess(_ completion: @escaping () -> Void) {
        print("[IN NODE - doProcess]: Processing deferred...")
        completion()
        print("[IN NODE - doProcess]: Processing deferred done!")
        if let processedCallback = processed {
            print("[IN NODE - doProcess]: Calling processed callback!")
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
        
        performanceInterations = 10000
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
    
// Disabled, not working
    
//    func test_deferredProcessingPerformance() {
//        let measureExpectation = expectation(description: "measure time")
//        measure(block: {[weak self] (completion) in
//            print("Processing deferred...")
//            guard let strongSelf = self else {
//                print("self not existing ")
//                return
//            }
//            strongSelf.deferredTestNode.processed = {
//                print("Processing deferred done!")
//                completion()
//            }
//            strongSelf.deferredTestNode.process()
//        }, iterations: performanceInterations!) {[weak self] (time) in
//            guard let strongSelf = self else {
//                print("FAILED")
//                return
//            }
//            let totalTime = time * 1000
//            let averageTime = totalTime / Double(strongSelf.performanceInterations!)
//
//            print("\nDeferred processing performance Total (ms): \(String(describing: totalTime)) \nAverage (ms): \(String(describing: averageTime)) \nIterations: \(String(describing: strongSelf.performanceInterations))\n")
//            measureExpectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 5.0, handler: nil)
//    }
    
    func test_allARgumentsAreSetBeforeDeferredProcessing() {
        let argumentsExpectation = expectation(description: "Both arguments set")
        
        let arg1 = 58
        let arg2 = 42
        
        deferredTestNode.aInput.value = arg1
        
        deferredTestNode.processed = {[weak self] in
            guard let strongSelf = self else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(strongSelf.deferredTestNode.aInput.value, arg1)
            XCTAssertEqual(strongSelf.deferredTestNode.bInput.value, arg2)
            argumentsExpectation.fulfill()
        }
        
        deferredTestNode.bInput.value = arg2
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func test_directProcessingTriggersOnFirstArgumentSet() {
        let arg1 = 58
        let arg2 = 42
        
        var triggerCount = 0
        deferredTestNode.deferred = false
        deferredTestNode.processed = {[weak self] in
            guard let strongSelf = self else {
                XCTFail()
                return
            }
            XCTAssertEqual(strongSelf.deferredTestNode.aInput.value, arg1)
            if triggerCount == 0 {
                XCTAssertNil(strongSelf.deferredTestNode.bInput.value)
            }
            
            triggerCount += 1
        }
        
        deferredTestNode.aInput.value = arg1
        deferredTestNode.bInput.value = arg2
        
        XCTAssertEqual(triggerCount, 2)
    }
    
    // MARK: Helpers
    func measure(block: @escaping ((_ completion: @escaping () -> Void ) -> Void),
                 iterations: NSInteger,
                 completion: @escaping (_ time: TimeInterval) -> Void) {
        let start = Date().timeIntervalSince1970
        var testTime: TimeInterval = 0.0
    
        var operations = [Operation]()
        for _ in 0...iterations {
            let blockOperation = DeferredAsyncOperation(withBlock: block)
            if let lastOperation = operations.last {
                blockOperation.addDependency(lastOperation)
            }
            operations.append(blockOperation)
        }
        
        let completionOperation = BlockOperation {
            testTime = Date().timeIntervalSince1970 - start
            completion(testTime)
        }
        
        if let lastOperation = operations.last {
            completionOperation.addDependency(lastOperation)
        }
        
        operations.append(completionOperation)
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.addOperations(operations, waitUntilFinished: true)
    }
}

class AsyncOperation: Operation {
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state",
                                           attributes: .concurrent)
    private var _state: OperationState = .ready
    
    @objc private dynamic var state: OperationState {
        get {
            return stateQueue.sync {
                _state
            }
        }
        
        set {
            stateQueue.async(flags: .barrier) {
                self._state = newValue
            }
        }
    }
    
    open override var isReady: Bool {
        return state == .ready && super.isReady
    }
    
    public final override var isExecuting: Bool {
        return state == .executing
    }
    
    public final override var isFinished: Bool {
        return state == .finished
    }
    
    public final override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        state = .executing
        
        main()
    }
    
    open override func main() {
        fatalError()
    }
    
    public final func finish() {
        if !isFinished {
            state = .finished
        }
    }
}

class DeferredAsyncOperation: AsyncOperation {
    let deferredBlock: ((_ : @escaping () -> Void ) -> Void)
    
    init(withBlock block: @escaping ((_ completion: @escaping () -> Void ) -> Void)) {
        deferredBlock = block
    }
    
    override func main() {
        deferredBlock() {[weak self] in
            print("finished")
            self?.finish()
        }
    }
}
