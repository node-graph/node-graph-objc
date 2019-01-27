#import "Node.h"

@interface AbstractNode ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NodeInput *> *inputs
@property (nonatomic, strong) NSMutableSet<NodeOutput> *outputs;

@property (nonatomic, assign) NSUInteger locks;
@property (nonatomic, assign) BOOL processWhenUnlocked;
@property (nonatomic, assign, getter=isProcessing) BOOL processing;

@end

@implementation AbstractNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _locks = 0;
        _inputs = [NSMutableDictionary new];
        _outputs = [NSMutableSet set];
    }
    
    return self;
}


#pragma mark - Actions

- (void)process {
    if (self.locks > 0) {
        self.processWhenUnlocked = YES;
        return;
    }
    self.processWhenUnlocked = NO;
    self.processing = YES;
    
    [self onProcess:^(id  _Nonnull result) {
        self.processing = NO;
        // Done processing, call downstream nodes
        [self passResultToDownstreamNodes:result];
    }];
}

- (void)lock {
    self.locks += 1;
}

- (void)unlock {
#if DEBUG
    assert(self.locks != 0);
#endif
    self.locks -= 1;
    if (self.locks == 0 && self.processWhenUnlocked) {
        [self process];
    }
}


#pragma mark - Private Actions

- (void)passResultToDownstreamNodes:(id)result {
    for (NodeOutput *output in self.outputs) {
        // Update output
    }
}



- (BOOL)canRun {
    switch (self.combinationType) {
        case NodeCombinationTypeAny: {
            __block BOOL canRun = NO;
            [self.inputs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NodeInput * _Nonnull obj, BOOL * _Nonnull stop) {
                if (obj.value != nil) {
                    canRun = YES;
                    *stop = YES;
                }
            }];
            return canRun;
            break;
        }
        case NodeCombinationTypeWhenAll: {
            __block BOOL canRun = YES;
            [self.inputs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NodeInput * _Nonnull obj, BOOL * _Nonnull stop) {
                if (obj.value == nil) {
                    canRun = NO;
                    *stop = YES;
                }
            }];
            return canRun;
        }
        case NodeCombinationTypeWhenAllAtLeastOnce: {
            
        }
        default:
            return NO;
            break;
    }
}

- (void)distributeToSubNodes {
    [self.outputs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NodeOutputCollection * _Nonnull outputCollection, BOOL * _Nonnull stop) {
        for (Node *output in outputCollection.outputs) {
            [output performForInput:outputCollection.key withValue:outputCollection.value];
        }
    }];
}

- (void)addOutput:(Node *)output {
    for (NSString *key in self.outputs.allKeys) {
        [self addOutput:output forKey:key];
    }
}

- (void)addOutput:(Node *)output forKey:(NSString *)key {
    NSAssert([self.outputs.allKeys containsObject:key], @"Node does not output the provided key");
    NSAssert([output.inputs.allKeys containsObject:key], @"Output does not take key");
    
    [self.outputs[key].outputs addObject:output];
}

@end
