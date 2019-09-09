#import <Foundation/Foundation.h>
#import "NGNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Holds a set of nodes that are or are not connected to each other. The set is only valid if
 each node in the set (if connected) only connects to a node that exists in the same set.
 */
@interface GraphNode : NSObject <SerializableNode>

/**
 Can be serialized.
 */
@property (nonatomic, readonly, getter=isSerializable) BOOL serializable;

/**
 The nodes currently held by the graph.
 */
@property (nonatomic, strong, readonly) NSSet<id<NGNode>> *nodes;

/**
 The node set that this graph should represent.
 @param nodes A collection of nodes that are only connected to other nodes within the same set.
 */
- (void)setNodeSet:(NSSet <id<NGNode>> *)nodes;

@end

NS_ASSUME_NONNULL_END
