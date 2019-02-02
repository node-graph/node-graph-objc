#import "Node.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface UpdateBackgroundColorNode : AbstractNode

@property (nonatomic, strong) NodeInput *colorInput;

- (instancetype)initWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
