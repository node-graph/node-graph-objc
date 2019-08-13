#import "NodeInputNumber.h"

@implementation NodeInputNumber
@dynamic value;

- (instancetype)initWithKey:(NSString *)key node:(nullable id<NodeInputDelegate, Node>)node {
    self = [self initWithKey:key
                  validation:^BOOL(id  _Nonnull value) {return [value isKindOfClass:[NSNumber class]];}
                        node:node];
    return self;
}

@end
