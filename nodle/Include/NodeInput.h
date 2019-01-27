#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A type of input for a \c Node. This decides what type of input a node can accept.
 A node can accept more than one input by defining more of these.
 */
@interface NodeInput : NSObject

/**
 Value is only set if valid
 */
@property (nonatomic, strong, nullable) id value;
- (instancetype)initWithValidation:(BOOL (^)(id value))validationBlock;
- (BOOL)isValueValid:(id)value;

@end

NS_ASSUME_NONNULL_END
