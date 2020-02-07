
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
class NodeInput: Hashable, Codable {
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
    private var _value: AnyHashable? = nil
    
    /**
     The node that this input beloongs to. Receives events regarding input changes.
     */
    var node: NodeAndDelegate? = nil
    
    /**
     The optional key of this input for the node.
     */
    private(set) var key: String? = nil
    
    /**
     The block that validates incoming values.
     */
    private(set) var validationBlock: ((_: AnyHashable?) -> Bool)?
    
    
    private enum CodingKeys: String, CodingKey {
        case key = "key"
        case type = "type"
    }
    
    init() {

    }
    
    /**
     Create a new input.
     */
    init(withKey key: String?,
         forNode node: NodeAndDelegate?) {
        self.key = key
        self.node = node
    }
    
    required init(from decoder: Decoder) throws {
        fatalError()
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key ?? "no_key", forKey: .key)
        try container.encode(String(describing:type(of: self)), forKey: .type)
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
