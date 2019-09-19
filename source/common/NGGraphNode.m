#import "NGGraphNode.h"
#import "NGNodeSerializationUtils.h"

@interface NGGraphNode ()

@property (nonatomic, strong) NSSet<id<NGNode>> *nodes;
@property (nonatomic, strong) NSSet<NGNodeInput *> *inputs;
@property (nonatomic, strong) NSSet<NGNodeOutput *> *outputs;
@property (nonatomic, strong) NSSet<id<NGNode>> *startNodes;
@property (nonatomic, strong) NSSet<id<NGNode>> *endNodes;

@end

@implementation NGGraphNode

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    self.nodes = [NSSet set];
    self.inputs = [NSSet set];
    self.outputs = [NSSet set];
    self.startNodes = nil;
    self.endNodes = nil;
}

- (BOOL)isSerializable {
    for (id node in self.nodes) {
        if (![node respondsToSelector:@selector(serializedRepresentationAsDictionary)]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Node Protocol

- (NGNodeInputTrigger)inputTrigger {
    return NGNodeInputTriggerCustom;
}

- (void)process {
    for (id<NGNode> node in self.startNodes) {
        [node process];
    }
}

- (void)cancel {
    for (id<NGNode> node in self.startNodes) {
        [node cancel];
    }
}

#pragma mark - Actions

- (void)setNodeSet:(NSSet<id<NGNode>> *)nodes {
    [self reset];
    if (!nodes || ![self verifyNodeSetIsSelfContained:nodes]) {
        return;
    }
    
    _nodes = nodes;
    
    self.startNodes = [self findStartNodesInNodes:nodes];
    self.endNodes = [self findEndNodesInNodes:nodes];
    
    for (id<NGNode> node in self.startNodes) {
        self.inputs = [self.inputs setByAddingObjectsFromSet:node.inputs];
    }
    
    for(id<NGNode> node in self.endNodes) {
        self.outputs = [self.outputs setByAddingObjectsFromSet:node.outputs];
    }
}

#pragma mark - Private Actions

/**
 Node graphs should contain all nodes that are being referenced as outputs in a given set. and thus be "self contained"
 @return NO if a node was found that does not exist in the given set. YES if set is "self contained"
 */
- (BOOL)verifyNodeSetIsSelfContained:(NSSet <id<NGNode>> *)nodes {
    for (id<NGNode> node in nodes) {
        for (NGNodeOutput *output in node.outputs) {
            for (NGNodeInput *connection in output.connections) {
                if (![nodes containsObject:connection.node]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (NSSet *)findStartNodesInNodes:(NSSet<id<NGNode>> *)nodes {
    NSMutableSet *startNodes = [nodes mutableCopy];
    for (id<NGNode> node in nodes) {
        for (NGNodeOutput *output in node.outputs) {
            for (NGNodeInput *connection in output.connections) {
                // Remove any node from the set that is referenced as a connection to another node.
                // Doing this should leave only the nodes that are not connected to anything in the `startNodes` set.
                [startNodes removeObject:connection.node];
            }
        }
    }
    return [NSSet setWithSet:startNodes];
}

- (NSSet *)findEndNodesInNodes:(NSSet<id<NGNode>> *)nodes {
    NSMutableSet *endNodes = [NSMutableSet set];
    for (id<NGNode> node in nodes) {
        BOOL hasDownstreamNodes = NO;
        for (NGNodeOutput *output in node.outputs) {
            if (output.connections.count) {
                hasDownstreamNodes = YES;
                break;
            }
        }
        if (!hasDownstreamNodes) {
            // Add nodes which do not have any downstream nodes to the `endNodes`.
            [endNodes addObject:node];
        }
    }
    return [NSSet setWithSet:endNodes];
}

#pragma mark - Serializable Node

- (NSString *)serializedType {
    return NSStringFromClass([self class]);
}

- (NSDictionary *)serializedRepresentationAsDictionary {
    return [NGNodeSerializationUtils serializedRepresentationAsDictionaryFromNode:self];
}

- (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsWithNodeMapping:(NSDictionary<NSString *,id<NGSerializableNode>> *)nodeMapping {
    return [NGNodeSerializationUtils serializedOutputConnectionsFromNode:self
                                                       withNodeMapping:nodeMapping];
}

- (NSDictionary *)serializedData {
    NSDictionary<NSString *, id<NGSerializableNode>> *nodeMapping = (NSDictionary<NSString *, id<NGSerializableNode>> *)[self nodeMappingFromNodesSet:self.nodes];
    NSDictionary<NSString *, NSString *> *serializedNodeMapping = [self serializedNodesFromNodeMapping:nodeMapping];
    NSDictionary<NSString *, NSDictionary *> *serializedConnections = [self connectionsForNodesInNodeMapping:nodeMapping];
    return @{
             @"nodes": serializedNodeMapping,
             @"connections": serializedConnections
             };
}

#pragma mark - Serialization helpers

- (NSDictionary<NSString *, id<NGNode>> *)nodeMappingFromNodesSet:(NSSet<id<NGNode>> *)nodes {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSUInteger i = 0;
    for (id<NGNode> node in nodes) {
        // TODO: Generate better key?
        result[[NSString stringWithFormat:@"node-id-%lu", (unsigned long)i]] = node;
        i++;
    }
    return result;
}

/**
 Fails if any contained node is not a SerializableNode.
 */
- (NSDictionary<NSString *, NSDictionary *> *)connectionsForNodesInNodeMapping:(NSDictionary<NSString *, id<NGSerializableNode>> *)nodeMapping {
    NSMutableDictionary *connections = [NSMutableDictionary dictionary];
    [nodeMapping enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<NGSerializableNode>  _Nonnull node, BOOL * _Nonnull stop) {
        connections[key] = [node serializedOutputConnectionsWithNodeMapping:nodeMapping];
    }];
    return connections;
}

- (NSDictionary<NSString *, NSString *> *)serializedNodesFromNodeMapping:(NSDictionary<NSString *, id<NGSerializableNode>> *)nodes {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [nodes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<NGSerializableNode>  _Nonnull node, BOOL * _Nonnull stop) {
        result[key] = [node serializedRepresentationAsDictionary];
    }];
    return result;
}


@end
