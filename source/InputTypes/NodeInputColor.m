#import "NodeInputColor.h"

@implementation NodeInputColor

- (instancetype)initWithKey:(NSString *)key node:(id<NodeInputDelegate, Node>)node {
    self = [self initWithKey:key
                  validation:^BOOL(id  _Nonnull value) {return [value isKindOfClass:[UIColor class]];}
                        node:node];
    return self;
}

@end
