#import <Foundation/Foundation.h>

@class Node;

NS_ASSUME_NONNULL_BEGIN

@interface NodeOutput: NSObject

@property (nonatomic, weak) Node *node;
@property (nonatomic, strong) NSString *inputKey;

@end

NS_ASSUME_NONNULL_END
