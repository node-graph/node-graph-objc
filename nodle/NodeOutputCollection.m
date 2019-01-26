#import "NodeOutputCollection.h"

@implementation NodeOutputCollection

+ (instancetype)new {
    return [[NodeOutputCollection alloc] init];
}

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        _outputs = [NSMutableSet<Node *> new];
        _value = nil;
    }
    
    return self;
}

@end
