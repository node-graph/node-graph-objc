#import "NodeInputColor.h"

@implementation NodeInputColor

- (instancetype)initWithKey:(NSString *)key delegate:(id<NodeInputDelegate>)delegate {
    self = [self initWithKey:key
                  validation:^BOOL(id  _Nonnull value) {return [value isKindOfClass:[UIColor class]];}
                    delegate:delegate];
    return self;
}

@end
