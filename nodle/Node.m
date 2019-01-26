#import "Node.h"

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
        case NodeCombinationTypeAny:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (void)distributeToSubNodes {
    [self.outputs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSSet<NodeOutput *> * _Nonnull outputNodes, BOOL * _Nonnull stop) {
        for (NodeOutput *output in outputNodes) {
            if (output.node != nil) {
                [output.node performForInput:output.inputKey withValue:nil];
            }
        }
    }];
}

@end
