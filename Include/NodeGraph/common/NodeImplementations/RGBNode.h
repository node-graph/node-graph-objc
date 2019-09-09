#import "NGNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Should increase R, G and B values by 0.1
 */
@interface RGBNode : NGAbstractNode

@property (nonatomic, strong) NodeInput *rInput;
@property (nonatomic, strong) NodeInput *gInput;
@property (nonatomic, strong) NodeInput *bInput;

@property (nonatomic, strong) NodeOutput *rOutput;
@property (nonatomic, strong) NodeOutput *gOutput;
@property (nonatomic, strong) NodeOutput *bOutput;

@end

NS_ASSUME_NONNULL_END
