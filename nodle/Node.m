#import "Node.h"

@interface Node()

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NodeOutputCollection *> *outputs;

@end

@implementation Node

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputs = [NSDictionary new];
        _outputs = [NSDictionary new];
    }
    
    return self;
}

- (void)performForInput:(NSString *)inputKey withValue:(id)value {
    
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
