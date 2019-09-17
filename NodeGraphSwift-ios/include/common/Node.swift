import Foundation

/**
 Decides what inputs need to be set in order for a node to process.
 */
enum NodeInputTrigger {
    /// The node does not automatically process anything, you manually have to call the -process method.
    case noAutomaticProcessing
    /// Process as soon as any input is set.
    case any
    /// All inputs have to be triggered between each run for the node to process.
    case all
    /// Same as NodeInputRequirementAll but keeps the value so next run can start whenever any input is set.
    case allAtLeastOnce
    /// The processing behaviour is custom and driven by the node itself.
    case custom
}

/**
 A Node in NodeGraph can have multiple inputs of varying types as well as many outputs of
 different types.
 
 Let't take an Add Node as the simplest example. It would require at least two
 inputs but the result would only be one value. Downstream nodes can be
 specified in the outputs property however but they all receive the same result.
 
 
 Node example:
 
 20         4
 \        /
 --I0----I1--
 |            |
 |   Divide   |
 |  O = A / B |
 |            |
 -----O0-----
      |
      5
 
 */
protocol Node {
    /**
     Specifies what inputs need to be set in order for the node to process.
     */
    var inputTrigger: NodeInputTrigger { get }
    
    /**
     The inputs of this node, inputs do not reference upstream nodes but keeps a
     result from an upstream node that this node can use when -process is called.
     */
    var inputs: Set<NodeInput> { get }
    
    /**
     All downstream connections out from this node. When -process is run the result
     will be fed to each NodeOutput.
     */
    var outputs: Set<NodeOutput> { get }
    
    /**
     Human readable name of the node.
     */
    var nodeName: String? { get }
    
    /**
     Describes what the node does or can be used for.
     */
    var nodeDescription: String? { get }
    
    /**
     Processes the node with the current values stored in the inputs of this node.
     All outputs will be triggered with the result of this nodes operation.
     
     This method will also be triggered internally based on the inputTrigger specified by the node.
     */
    func process()
    
    /**
     Cancels the current processing and stops the result from flowing to any
     downstream nodes. Also recursively cancels any downstream connections.
     */
    func cancel()
}

class AbstractNode: Node, NodeInputDelegate {
    var inputTrigger: NodeInputTrigger
    var inputs: Set<NodeInput>
    var outputs: Set<NodeOutput>
    var nodeName: String?
    var nodeDescription: String?
    
    /**
     This method is called when processing is started to decide if the -doProcess:
     method should be called directly or deferred.
     The default behaviour looks at the number of inputs together with the
     inputTrigger property. Only override this method if the default behaviour is
     not suited for your application.
     
     The reason for deferring the processing call is to not run your implementation
     of the work that your node performs and all downstream nodes if multiple input
     parameters are being set in the same runloop.
     */
    var useDeferredProcessing: Bool {
        let couldTriggerOnAnyInput = (
            inputTrigger == .any ||
            inputTrigger == .allAtLeastOnce ||
            inputTrigger == .custom
        )
        return (inputs.count > 1 && couldTriggerOnAnyInput)
    }
    
    private(set) var isProcessing: Bool
    private(set) var processingTime: TimeInterval
    private var processingStartTime: TimeInterval
    private var cancelling: Bool
    
    init() {
        processingTime = 0
        inputTrigger = .any
        inputs = Set<NodeInput>()
        outputs = Set<NodeOutput>()
        isProcessing = false
        cancelling = false
        processingTime = 0.0
        processingStartTime = 0.0
        
    }
    
    // MARK: Actions
    
    /**
     Do not override this method directly to add your functionality. Instead
     override the -doProcess: method.
     */
    func process() {
        guard !isProcessing else {
            return
        }
        
        isProcessing = true
        processingStartTime = Date().timeIntervalSince1970
        if useDeferredProcessing {
            processDeferred()
        } else {
            processDirectly()
        }
    }
    
    func cancel() {
        guard !cancelling else {
            return
        }
        
        cancelling = true
        for output in outputs {
            for connection in output.connections.allObjects {
                guard let connectionNode = connection.node else {
                    return
                }
                connectionNode.cancel()
            }
        }
    }
    
    /**
     @abstract
     Implement this method with your Node functionality.
     1, Process input values
     2, Send result to each respective output
     3, Call completion block when done
     */
    func doProcess(_ completion: @escaping () -> Void) {
        sendResultsToOutputs(inputs.randomElement()?.value)
        completion()
    }
    
    private func sendResultsToOutputs(_ results: AnyHashable?) {
        for output in outputs {
            output.send(result: results)
        }
    }
    
    // MARK: Processing
    
    private func processDeferred() {
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.processDirectly()
        }
    }
    
    private func processDirectly() {
        doProcess {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.processingTime = Date().timeIntervalSince1970 - strongSelf.processingTime
            strongSelf.isProcessing = false
        }
    }
    
    func nodeInputDidUpdateValue(_: NodeInput, value: AnyHashable?) {
        if canRun() {
            process()
        }
    }
    
    private func canRun() -> Bool {
        var canRunNode = false
        switch inputTrigger {
        case .any:
            canRunNode = false
            for input in inputs {
                if input.value != nil {
                    canRunNode = true
                    continue
                }
            }
            break
        case .all:
            canRunNode = true
            for input in inputs {
                if input.value == nil {
                    canRunNode = false
                }
            }
            break
        case .allAtLeastOnce:
            // TODO
            break
        case .noAutomaticProcessing:
            canRunNode = false
            break
        case .custom:
            canRunNode = true
            break
        }
        
        return canRunNode
    }
}
