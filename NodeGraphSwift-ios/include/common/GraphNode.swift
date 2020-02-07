import UIKit

class GraphNode: NSObject {
    var serializeable: Bool {
        for node in nodes {
            guard let _ = node as? SerializableNode else {
                return false
            }
        }
        
        return true
    }
    private(set) var nodes: Set<AnyHashable> = Set<AnyHashable>()
    
    func set<HashableNode>(nodeSet: Set<HashableNode>) where HashableNode: Node, HashableNode: Hashable {
        nodes = nodeSet
    }
}

