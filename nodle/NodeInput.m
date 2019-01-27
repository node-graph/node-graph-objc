#import "NodeInput.h"

@interface NodeInput ()

@property (nonatomic, strong, nullable) NSString *key;

@end

@implementation NodeInput

- (instancetype)initWithKey:(NSString *)key
                 validation:(BOOL (^)(id _Nonnull))validationBlock
                   delegate:(id<NodeInputDelegate>)delegate {
    self = [super init];
    if (self) {
        _key = key;
        _validationBlock = validationBlock;
        _delegate = delegate;
    }
    return self;
}

- (void)setValue:(id)value {
    if (![self valueIsValid:value]) {
        return;
    }
    _value = value;
    [self.delegate nodeInput:self didUpdateValue:_value];
}

- (BOOL)valueIsValid:(id)value {
    if (!self.validationBlock) {
        return YES;
    }
    return self.validationBlock(value);
}

@end
