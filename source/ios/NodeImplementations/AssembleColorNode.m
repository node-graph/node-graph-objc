#import "AssembleColorNode.h"
#import <UIKit/UIKit.h>
#import "NGNodeInputNumber.h"

@implementation AssembleColorNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputTrigger = NGNodeInputTriggerAll;

        _rInput = [[NGNodeInputNumber alloc] initWithKey:@"r" node:self];
        _gInput = [[NGNodeInputNumber alloc] initWithKey:@"g" node:self];
        _bInput = [[NGNodeInputNumber alloc] initWithKey:@"b" node:self];
        _inputs = [NSSet setWithObjects:_rInput, _gInput, _bInput, nil];
        
        _colorOutput = [[NGNodeOutput alloc] initWithKey:@"color"];
        _outputs = [NSSet setWithObject:_colorOutput];
    }
    
    return self;
}

- (void)doProcess:(void (^)(void))completion {
    CGFloat r = [self.rInput.value floatValue],
            g = [self.gInput.value floatValue],
            b = [self.bInput.value floatValue];
    [self.colorOutput sendResult:[UIColor colorWithRed:r green:g blue:b alpha:1.0f]];
    completion();
}

@end
