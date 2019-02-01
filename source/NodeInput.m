#import "NodeInput.h"

@interface NodeInput ()

@property (nonatomic, strong, nullable) NSString *key;

@end

@implementation NodeInput

+ (instancetype)inputWithKey:(NSString *)key delegate:(id<NodeInputDelegate>)delegate {
    return [[self alloc] initWithKey:key delegate:delegate];
}

+ (instancetype)inputWithKey:(NSString *)key
                  validation:(nullable BOOL (^)(id _Nullable))validationBlock
                    delegate:(nullable id<NodeInputDelegate>)delegate {
    return [[self alloc] initWithKey:key validation:validationBlock delegate:delegate];
}

- (instancetype)initWithKey:(NSString *)key
                   delegate:(id<NodeInputDelegate>)delegate {
    self = [super init];
    if (self) {
        _key = key;
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key
                 validation:(nullable BOOL (^)(id _Nullable))validationBlock
                   delegate:(nullable id<NodeInputDelegate>)delegate {
    self = [self initWithKey:key delegate:delegate];
    if (self) {
        _validationBlock = validationBlock;
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

- (BOOL)valueIsValid:(id _Nullable)value {
    if (!self.validationBlock) {
        return YES;
    }
    return self.validationBlock(value);
}

@end
