#import <Foundation/Foundation.h>
#import "NodeInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface NodeInputNumber : NodeInput

@property (nonatomic, strong, nullable) NSNumber *value;

@end

NS_ASSUME_NONNULL_END
