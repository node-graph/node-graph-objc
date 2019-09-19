#import <Foundation/Foundation.h>
#import "NGNodeInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGNodeInputNumber : NGNodeInput

@property (nonatomic, strong, nullable) NSNumber *value;

@end

NS_ASSUME_NONNULL_END
