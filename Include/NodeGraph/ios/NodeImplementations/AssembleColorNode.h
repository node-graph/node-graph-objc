#import "NGNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Takes RGB input and turns into UIColor
 */
@interface AssembleColorNode : NGAbstractNode

@property (nonatomic, strong) NodeInput *rInput;
@property (nonatomic, strong) NodeInput *gInput;
@property (nonatomic, strong) NodeInput *bInput;

@property (nonatomic, strong) NodeOutput *colorOutput;

@end

NS_ASSUME_NONNULL_END
