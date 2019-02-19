#import "NSDictionary+NSMapTable.h"

@implementation NSDictionary (NSMapTable)

- (NSMapTable<id,NSString *> *)mapWithFlipedKeysAndValues {
    NSMapTable *flipped = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    for (NSString *key in self.allKeys) {
        [flipped setObject:key forKey:self[key]];
    }
    return flipped;
}

@end
