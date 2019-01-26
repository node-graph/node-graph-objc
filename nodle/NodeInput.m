#import "NodeInput.h"

@implementation NodeInput

- (instancetype)initWithType:(Class)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    
    return self;
}

- (BOOL)isValueValid:(id)value {
    return [value isKindOfClass:self.type];
}

@end
