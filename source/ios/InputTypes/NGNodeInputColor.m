#import "NGNodeInputColor.h"

@implementation NGNodeInputColor
@dynamic value;

- (instancetype)initWithKey:(NSString *)key node:(id<NGNodeInputDelegate, NGNode>)node {
    self = [self initWithKey:key
                  validation:^BOOL(id  _Nonnull value) {return [value isKindOfClass:[UIColor class]];}
                        node:node];
    return self;
}

@end
