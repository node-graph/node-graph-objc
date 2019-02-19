#import <Foundation/Foundation.h>
#import "Node.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Holds a chain/tree of nodes
 */
@interface NodeTree : NSObject <SerializableNode>

@property (nonatomic, readonly, getter=isSerializable) BOOL serializable;

- (void)holdNodeChainWithStartNodes:(NSSet <id<Node>> *)nodes;

@end

NS_ASSUME_NONNULL_END
