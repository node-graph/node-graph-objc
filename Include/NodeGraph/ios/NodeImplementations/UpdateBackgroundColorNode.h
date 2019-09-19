#import "NGNode.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface UpdateBackgroundColorNode : NGAbstractNode

@property (nonatomic, strong) NGNodeInput *colorInput;

- (instancetype)initWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
