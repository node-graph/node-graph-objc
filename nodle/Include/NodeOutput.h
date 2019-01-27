#import <Foundation/Foundation.h>

@class Node;

NS_ASSUME_NONNULL_BEGIN

/**
 An output to send the processed result from a node on to another node.
 */
@interface NodeOutput: NSObject

/**
 The downstream node that gets the result of this node.
 */
@property (nonatomic, weak) Node *node;

/**
 What input key on the receiving node this is mapped to.
 */
@property (nonatomic, strong) NSString *inputKey;

@end

NS_ASSUME_NONNULL_END
