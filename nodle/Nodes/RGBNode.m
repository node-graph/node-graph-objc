#import "RGBNode.h"

@implementation RGBNode

@synthesize inputs;
@synthesize outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        inputs = @{
                   @"R": [[NodeInput alloc] initWithType:[NSNumber class]],
                   @"G": [[NodeInput alloc] initWithType:[NSNumber class]],
                   @"B": [[NodeInput alloc] initWithType:[NSNumber class]]
                   };
        
        outputs = @{
                    @"R": [[NSSet<NodeOutput *> alloc] init],
                    @"G": [[NSSet<NodeOutput *> alloc] init],
                    @"B": [[NSSet<NodeOutput *> alloc] init]
                    };
    }
    
    return self;
}

- (void)performForInput:(NSString *)inputKey withValue:(id)value {
    if (![inputs.allKeys containsObject:inputKey] ||
        ![[inputs objectForKey:inputKey] isValueValid:value]) {
        return;
    }
    
    [inputs objectForKey:inputKey].value = value;
    
    if ([self canRun]) {
        [self superSeriousBusinessLogicFunc];
        [super distributeToSubNodes];
    }
}

- (void)superSeriousBusinessLogicFunc {
    
}

@end
