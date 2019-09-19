#import "RGBNode.h"
#import <CoreGraphics/CGBase.h>
#import "NGNodeInputNumber.h"

@implementation RGBNode

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
        
        _rOutput = [[NGNodeOutput alloc] initWithKey:@"r"];
        _gOutput = [[NGNodeOutput alloc] initWithKey:@"g"];
        _bOutput = [[NGNodeOutput alloc] initWithKey:@"b"];
        
        _inputs = [NSSet setWithObjects:_rInput, _gInput, _bInput, nil];
        _outputs = [NSSet setWithObjects:_rOutput, _gOutput, _bOutput, nil];
    }
    
    return self;
}

- (void)doProcess:(void (^)(void))completion {
    CGFloat r = [self.rInput.value floatValue],
            g = [self.gInput.value floatValue],
            b = [self.bInput.value floatValue];
    
    [self.rOutput sendResult:@(r + 0.1)];
    [self.gOutput sendResult:@(g + 0.1)];
    [self.bOutput sendResult:@(b + 0.1)];
    completion();
}

@end
