#import "NGNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Takes RGB input and turns into UIColor
 */
@interface AssembleColorNode : NGAbstractNode

@property (nonatomic, strong) NGNodeInput *rInput;
@property (nonatomic, strong) NGNodeInput *gInput;
@property (nonatomic, strong) NGNodeInput *bInput;

@property (nonatomic, strong) NGNodeOutput *colorOutput;

@end

NS_ASSUME_NONNULL_END
