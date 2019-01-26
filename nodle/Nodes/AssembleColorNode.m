#import "AssembleColorNode.h"
#import <UIKit/UIKit.h>

@implementation AssembleColorNode

@synthesize inputs = _inputs;
@synthesize outputs = _outputs;
@synthesize combinationType = _combinationType;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputs = @{
                    @"R": [[NodeInput alloc] initWithType:[NSNumber class]],
                    @"G": [[NodeInput alloc] initWithType:[NSNumber class]],
                    @"B": [[NodeInput alloc] initWithType:[NSNumber class]]
                    };
        
        _outputs = @{
                     @"COLOR": [[NodeOutputCollection alloc] initWithKey:@"COLOR"]
                     };
        
        _combinationType = NodeCombinationTypeWhenAll;
    }
    
    return self;
}

- (void)performForInput:(NSString *)inputKey withValue:(id)value {
    if (![self.inputs.allKeys containsObject:inputKey] ||
        ![[self.inputs objectForKey:inputKey] isValueValid:value]) {
        return;
    }
    
    [self.inputs objectForKey:inputKey].value = value;
    
    if ([self canRun]) {
        [self superSeriousBusinessLogicFunc];
        [super distributeToSubNodes];
    }
}

- (void)superSeriousBusinessLogicFunc {
    CGFloat r = [((NSNumber *)self.inputs[@"R"].value) floatValue],
            g = [((NSNumber *)self.inputs[@"G"].value) floatValue],
            b = [((NSNumber *)self.inputs[@"B"].value) floatValue];
    
    self.outputs[@"COLOR"].value = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}

@end
