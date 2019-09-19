
/**
 Defines how a node input communicates changes.
 */
protocol NodeInputDelegate {
    func nodeInputDidUpdateValue(_: NodeInput, value:AnyHashable?) -> Void
}

/**
 A type of input for a \c Node. This decides what type of input a node can accept.
 A node can accept more than one input by defining more of these.
 
 This class is well suited for subclassing so you can implement inputs for specific types.
 */
class NodeInput: Hashable {
    typealias NodeAndDelegate = Node & NodeInputDelegate
    
    /**
     The current value of the input. The setter will run the validationBlock before
     trying to store the value.
     */
    var value: AnyHashable? {
        set {
            guard valueIsValid(newValue) else {
                return
            }
            
            if _value != nil && _value == newValue {
                return
            }
            
            _value = newValue
            
            if let node = node {
                node.nodeInputDidUpdateValue(self, value: _value)
            }
        }
        get {
            return _value
        }
    }
    private var _value: AnyHashable?
    
    /**
     The node that this input beloongs to. Receives events regarding input changes.
     */
    var node: NodeAndDelegate?
    
    /**
     The optional key of this input for the node.
     */
    private(set) var key: String?
    
    /**
     The block that validates incoming values.
     */
    private(set) var validationBlock: ((_: AnyHashable?) -> Bool)?
    
    init() {
        key = nil
        node = nil
    }
    
    /**
     Create a new input.
     */
    init(withKey key: String?,
         forNode node: NodeAndDelegate?) {
        self.key = key
        self.node = node
    }
    
    /**
     Create a new input.
     */
    init(withKey key: String?,
         forNode node: NodeAndDelegate?,
         withValidationBlock validationBlock: ((_: AnyHashable?) -> Bool)?) {
        self.key = key
        self.node = node
        self.validationBlock = validationBlock
    }
    
    static func == (lhs: NodeInput, rhs: NodeInput) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node?.nodeName)
        hasher.combine(key)
    }
    
    /**
     Checks if value is valid or not.
     */
    func valueIsValid(_ value: AnyHashable?) -> Bool {
        guard let validationBlock = validationBlock else {
            return true
        }
        return validationBlock(value)
    }
}
