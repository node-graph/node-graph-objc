#import "AssembleColorNode.h"
#import <UIKit/UIKit.h>
#import "NodeInputNumber.h"

@interface AssembleColorNode ()

@property (nonatomic, strong) NodeInput *rInput;
@property (nonatomic, strong) NodeInput *gInput;
@property (nonatomic, strong) NodeInput *bInput;

@property (nonatomic, strong) NodeOutput *colorOutput;

@end

@implementation AssembleColorNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputTrigger = NodeInputTriggerAll;

        _rInput = [[NodeInputNumber alloc] initWithKey:@"r" delegate:self];
        _gInput = [[NodeInputNumber alloc] initWithKey:@"g" delegate:self];
        _bInput = [[NodeInputNumber alloc] initWithKey:@"b" delegate:self];
        _inputs = [NSSet setWithObjects:_rInput, _gInput, _bInput, nil];
        
        _colorOutput = [[NodeOutput alloc] initWithKey:@"color"];
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
