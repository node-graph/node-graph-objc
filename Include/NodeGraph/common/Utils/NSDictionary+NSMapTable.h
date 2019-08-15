#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (NSMapTable)

/**
 Returns a map with all values and keys flipped from the NSDictionary.
 ex:
 From:
  @{
      @"foo": @(10),
      @"bar": @(20)
   }
 To:
  @{
      @(10): @"foo",
      @(20): @"bar"
   }
 */
- (NSMapTable<id, NSString *> *)mapWithFlippedKeysAndValues;

@end

NS_ASSUME_NONNULL_END
