#import "NodeTree.h"
#import "NodeSerializationUtils.h"

@interface NodeTree ()

@property (nonatomic, strong) NSMutableSet<id<Node>> *nodes;
@property (nonatomic, strong) NSSet<NodeInput *> *inputs;
@property (nonatomic, strong) NSSet<NodeOutput *> *outputs;
@property (nonatomic, strong) NSSet<id<Node>> *startNodes;

@end

@implementation NodeTree

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    self.nodes = [NSMutableSet set];
    self.inputs = [NSSet set];
    self.outputs = [NSSet set];
    self.startNodes = nil;
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

- (NodeInputTrigger)inputTrigger {
    return NodeInputTriggerCustom;
}

- (void)process {
    for (id<Node> node in self.startNodes) {
        [node process];
    }
}

- (void)cancel {
    for (id<Node> node in self.startNodes) {
        [node cancel];
    }
}

#pragma mark - Actions

- (void)holdNodeChainWithStartNodes:(NSSet<id<Node>> *)nodes {
    [self reset];
    if (!nodes) {
        return;
    }
    self.startNodes = nodes;
    for (id<Node> node in nodes) {
        self.inputs = [self.inputs setByAddingObjectsFromSet:node.inputs];
        [self addNodeRecursively:node];
    }
}

#pragma mark - Private Actions

- (void)addNodeRecursively:(id<Node>)node {
    [self.nodes addObject:node];
    BOOL hasDownstreamNodes = NO;
    for (NodeOutput *output in node.outputs) {
        for (NodeInput *connection in output.connections) {
            [self addNodeRecursively:connection.node];
            hasDownstreamNodes = YES;
        }
    }
    if (!hasDownstreamNodes) {
        self.outputs = [self.outputs setByAddingObjectsFromSet:node.outputs];
    }
}

#pragma mark - Serializable Node

- (NSString *)serializedType {
    return NSStringFromClass([self class]);
}

- (NSDictionary *)serializedRepresentationAsDictionary {
    return [NodeSerializationUtils serializedRepresentationAsDictionaryFromNode:self];
}

- (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsWithNodeMapping:(NSDictionary<NSString *,id<SerializableNode>> *)nodeMapping {
    return [NodeSerializationUtils serializedOutputConnectionsFromNode:self
                                                       withNodeMapping:nodeMapping];
}

- (NSDictionary *)serializedData {
    // TODO: Serialize connections and stuff
    NSDictionary<NSString *, id<Node>> *nodeMapping = [self nodeMappingFromNodesSet:self.nodes];
    NSDictionary<NSString *, NSString *> *serializedNodeMapping = [self serializedNodesFromNodeMapping:nodeMapping];
    NSDictionary<NSString *, NSDictionary *> *serializedConnections = [self connectionsForNodesInNodeMapping:nodeMapping];
    return @{
             @"nodes": serializedNodeMapping,
             @"connections": serializedConnections
             };
}

#pragma mark - Serialization helpers

// TODO: Recursive serialization of all nodes in the tree

- (NSDictionary<NSString *, id<Node>> *)nodeMappingFromNodesSet:(NSSet<id<Node>> *)nodes {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSUInteger i = 0;
    for (id<Node> node in nodes) {
        // TODO: Generate better key?
        result[[NSString stringWithFormat:@"node-id-%lu", (unsigned long)i]] = node;
        i++;
    }
    return result;
}

/**
 Fails if any contained node is not a SerializableNode.
 */
- (NSDictionary<NSString *, NSDictionary *> *)connectionsForNodesInNodeMapping:(NSDictionary<NSString *, id<SerializableNode>> *)nodeMapping {
    NSMutableDictionary *connections = [NSMutableDictionary dictionary];
    [nodeMapping enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<SerializableNode>  _Nonnull node, BOOL * _Nonnull stop) {
        connections[key] = [node serializedOutputConnectionsWithNodeMapping:nodeMapping];
    }];
    return connections;
}

- (NSDictionary<NSString *, NSString *> *)serializedNodesFromNodeMapping:(NSDictionary<NSString *, id<SerializableNode>> *)nodes {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [nodes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<SerializableNode>  _Nonnull node, BOOL * _Nonnull stop) {
        result[key] = [node serializedRepresentationAsDictionary];
    }];
    return result;
}


@end
