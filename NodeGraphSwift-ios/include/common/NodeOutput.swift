import Foundation

/**
 A representation of an output from a Node. An output can be named with a key to
 signify what part of the result it carries.
 
 An output has connections as weak references to instances of NodeInput.
 */
class NodeOutput: Hashable, Codable {
    /**
     The key of this output, can be nil if the node only has one output.
     An example value for this could be the `R` output key in an `RGB` node.
     */
    private(set) var key: String? = nil
    
    /**
     The downstream node inputs that gets the result of this output.
     @warning Please do not mutate this object directly.
     */
    private(set) var connections: NSHashTable<NodeInput> = NSHashTable(options: NSPointerFunctions.Options.weakMemory)
    
    private enum CodingKeys: String, CodingKey {
        case key = "key"
        case type = "type"
    }
    
    /**
     Creates an output without a key.
     */
    init() {

    }
    
    /**
     Creates an output with a key/name.
     */
    init(withKey key: String) {
        self.key = key
        connections = NSHashTable(options: NSPointerFunctions.Options.weakMemory)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError()
    }
    
    static func == (lhs: NodeOutput, rhs: NodeOutput) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(connections)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key ?? "no_key", forKey: .key)
        try container.encode(String(describing: type(of: self)), forKey: .type)
    }
    
    /**
     Adds a downstream connection from this output.
     */
    func addConnection(nodeInput: NodeInput) {
        connections.add(nodeInput)
    }
    
    /**
     Removes a downstream connection from this output.
     */
    func removeConnection(nodeInput: NodeInput) {
        connections.remove(nodeInput)
    }
    
    /**
     Sends the result to each connection.
     */
    func send(result: AnyHashable?) {
        for connection in connections.allObjects {
            connection.value = result
        }
    }
}
