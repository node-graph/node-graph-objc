#import <Foundation/Foundation.h>
#import <nodle/nodle.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Holds a chain/tree of nodes
 */
@interface NodeTree : NSObject <Node>

- (void)holdNodeChainWithStartNodes:(NSSet <id<Node>> *)nodes;

@end

NS_ASSUME_NONNULL_END
