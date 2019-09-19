#import <UIKit/UIKit.h>
#import "UpdateBackgroundColorNode.h"
#import "NGNodeInputColor.h"

@interface UpdateBackgroundColorNode ()

@property (nonatomic, weak) UIView *view;

@end

@implementation UpdateBackgroundColorNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
        _inputTrigger = NGNodeInputTriggerAny;
        _colorInput = [[NGNodeInputColor alloc] initWithKey:@"color" node:self];
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
