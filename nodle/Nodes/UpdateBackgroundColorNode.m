#import <UIKit/UIKit.h>
#import "UpdateBackgroundColorNode.h"

@interface UpdateBackgroundColorNode()

@property (nonatomic, weak) UIView *view;

@end

@implementation UpdateBackgroundColorNode

@synthesize inputs = _inputs;
@synthesize outputs = _outputs;
@synthesize combinationType = _combinationType;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
        _inputs = @{
                    @"COLOR": [[NodeInput alloc] initWithType:[UIColor class]]
                    };
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
        [self updateColor];
        [super distributeToSubNodes];
    }
}

- (void)updateColor {
    if (self.view == nil) {
        return;
    }
    
    self.view.backgroundColor = (UIColor *)self.inputs[@"COLOR"].value;
}

@end
