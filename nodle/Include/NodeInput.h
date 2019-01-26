#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeInput : NSObject

@property (nonatomic, readonly) Class type;
@property (nonatomic, strong) id value;

- (instancetype)initWithType:(Class)type;

- (BOOL)isValueValid:(id)value;

@end

NS_ASSUME_NONNULL_END
