#import <UIKit/UIKit.h>
#import "UpdateBackgroundColorNode.h"
#import "NodeInputColor.h"

@interface UpdateBackgroundColorNode ()

@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NodeInput *colorInput;

@end

@implementation UpdateBackgroundColorNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
        _inputTrigger = NodeInputTriggerAny;
        _colorInput = [[NodeInputColor alloc] initWithKey:@"color" node:self];
        _inputs = [NSSet setWithObject:_colorInput];
        _outputs = [NSSet set];
    }
    
    return self;
}

- (void)doProcess:(void (^)(void))completion {
    [self updateColor];
    completion();
}

- (void)updateColor {
    if (self.view == nil) {
        return;
    }
    
    self.view.backgroundColor = self.colorInput.value;
}

@end
