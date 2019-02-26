#import "NodeSerializationUtils.h"
#import "Node.h"
#import "NSDictionary+NSMapTable.h"

@implementation NodeSerializationUtils

+ (NSDictionary *)serializedRepresentationAsDictionaryFromNode:(id<SerializableNode>)node {
    NSMutableArray *inputs = [NSMutableArray array];
    for (NodeInput *input in node.inputs) {
        [inputs addObject:input.key ?: @"no_key"];
    }
    NSMutableArray *outputs = [NSMutableArray array];
    for (NodeOutput *output in node.outputs) {
        [outputs addObject:output.key ?: @"no_key"];
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"type": [node serializedType],
                                                                                  @"inputs": inputs,
                                                                                  @"outputs": outputs
                                                                                  }];
    if ([(id)node respondsToSelector:@selector(nodeName)]) {
        result[@"name"] = node.nodeName;
    }
    if ([(id)node respondsToSelector:@selector(nodeDescription)]) {
        result[@"description"] = node.nodeDescription;
    }
    if ([(id)node respondsToSelector:@selector(serializedData)]) {
        result[@"data"] = [node serializedData];
    }
    return result;
}

+ (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsFromNode:(id<SerializableNode>)node
                                                             withNodeMapping:(NSDictionary<NSString *, id<SerializableNode>> *)nodeMapping {
    NSMapTable *nodesAsKeys = [nodeMapping mapWithFlippedKeysAndValues];
    
    NSMutableDictionary *outputs = [NSMutableDictionary dictionary];
    for (NodeOutput *output in node.outputs) {
        NSMutableArray *connections = [NSMutableArray array];
        for (NodeInput *connection in output.connections) {
            [connections addObject:@{
                                     @"node": [nodesAsKeys objectForKey:connection.node],
                                     @"input": connection.key ?: @"no_key"
                                     }];
        }
        outputs[output.key ?: @"no_key"] = connections;
    }
    
    return outputs;
}

@end
