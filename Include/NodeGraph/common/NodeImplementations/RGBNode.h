#import "NGNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Should increase R, G and B values by 0.1
 */
@interface RGBNode : NGAbstractNode

@property (nonatomic, strong) NGNodeInput *rInput;
@property (nonatomic, strong) NGNodeInput *gInput;
@property (nonatomic, strong) NGNodeInput *bInput;

@property (nonatomic, strong) NGNodeOutput *rOutput;
@property (nonatomic, strong) NGNodeOutput *gOutput;
@property (nonatomic, strong) NGNodeOutput *bOutput;

@end

NS_ASSUME_NONNULL_END
