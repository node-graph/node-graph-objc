#import "NGNodeInput.h"

@interface NGNodeInput ()

@property (nonatomic, strong, nullable) NSString *key;

@end

@implementation NGNodeInput

+ (instancetype)inputWithKey:(NSString *)key node:(nullable id<NGNodeInputDelegate, NGNode>)node {
    return [[self alloc] initWithKey:key node:node];
}

+ (instancetype)inputWithKey:(NSString *)key
                  validation:(nullable BOOL (^)(id _Nullable))validationBlock
                        node:(nullable id<NGNodeInputDelegate, NGNode>)node {
    return [[self alloc] initWithKey:key validation:validationBlock node:node];
}

- (instancetype)initWithKey:(NSString *)key
                       node:(nullable id<NGNodeInputDelegate, NGNode>)node {
    self = [super init];
    if (self) {
        _key = key;
        _node = node;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key
                 validation:(nullable BOOL (^)(id _Nullable))validationBlock
                       node:(nullable id<NGNodeInputDelegate, NGNode>)node {
    self = [super init];
    if (self) {
        _key = key;
        _node = node;
        _validationBlock = validationBlock;
    }
    return self;
}

- (void)setValue:(id)value {
    if (_value == value || ![self valueIsValid:value]) {
        return;
    }
    _value = value;
    [self.node nodeInput:self didUpdateValue:_value];
}

- (BOOL)valueIsValid:(id _Nullable)value {
    if (!self.validationBlock) {
        return YES;
    }
    return self.validationBlock(value);
}

@end
