#import "NodeTree.h"

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

@end
