#import "NGNodeSerializationUtils.h"
#import "NGNode.h"
#import "NSDictionary+NSMapTable.h"

@implementation NGNodeSerializationUtils

+ (NSDictionary *)serializedRepresentationAsDictionaryFromNode:(id<NGSerializableNode>)node {
    NSMutableArray *inputs = [NSMutableArray array];
    for (NGNodeInput *input in node.inputs) {
        [inputs addObject:input.key ?: @"no_key"];
    }
    NSMutableArray *outputs = [NSMutableArray array];
    for (NGNodeOutput *output in node.outputs) {
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

+ (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsFromNode:(id<NGSerializableNode>)node
                                                             withNodeMapping:(NSDictionary<NSString *, id<NGSerializableNode>> *)nodeMapping {
    NSMapTable *nodesAsKeys = [nodeMapping mapWithFlippedKeysAndValues];
    
    NSMutableDictionary *outputs = [NSMutableDictionary dictionary];
    for (NGNodeOutput *output in node.outputs) {
        NSMutableArray *connections = [NSMutableArray array];
        for (NGNodeInput *connection in output.connections) {
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
