#import <Foundation/Foundation.h>
#import "NodeInput.h"
#import "NodeOutput.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Decides what inputs need to be set in order for a node to process.
 */
typedef NS_ENUM(NSUInteger, NodeInputRequirement) {
    /// Effectively the same as NodeCombinationTypeAny but signifies that the logic is defined by the node itself.
    NodeInputRequirementUndefined,
    /// Process as soon as any input is set.
    NodeInputRequirementAny,
    /// All inputs have to be triggered between each run for the node to process.
    NodeInputRequirementAll,
    /// Same as NodeInputRequirementAll but keeps the value so next run can start whenever any input is set.
    NodeInputRequirementAllAtLeastOnce,
};


/**
 A Node in Nodle can have multiple input types but only one type of output.
 
 Let't take an Add Node as the simplest example. It would require at least two inputs but the
 result would only be one value. Downstream nodes can be specified in the outputs property
 however but they all receive the same result.
 */
@protocol Node
@required

/**
 Specifies what inputs need to be set in order for the node to process.
 */
@property (nonatomic, assign, readonly) NodeInputRequirement inputRequirement;

/**
 The inputs of this node, inputs do not reference upstream nodes but keeps a result from an upstream node
 that this node can use when -process is called.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NodeInput *> *inputs;

/**
 All downstream nodes from this one. When -process is run the result will be fed as input to each NodeOutput.
 */
@property (nonatomic, strong, readonly) NSSet<NodeOutput *> *outputs;

/**
 Will add @c outputNode as output for @c key
 */
- (void)addOutput:(Node *)output forInputKey:(nullable NSString *)key;

/**
 Processes the node with the current values stored in the inputs of this node.
 All outputs will be triggered with the result of this nodes operation.
 
 This method will also be triggered internally based on the combinationType specified by the node.

 The -process method can be stalled by calling the -lock method. A corresponding call to -unlock must
 be made for each call to -lock.
 */
- (void)process;

/**
 Lock this node from running its process method. The lock is kept as a count and the corresponding
 -unlock method needs to be called for each call to the -lock method.
 
 This lock exists as a performance improvement to defer the call to the -processs method when multiple
 inputs are set in the same "tick".
 */
- (void)lock;

/**
 Unlock the node to allow it to process it's inputs. This decreases the lock count.
 */
- (void)unlock;

@end


/**
 Abstract class that you should subclass and implement in order to have a functioning Node.
 
 Methods to override:
 -process
 */
@interface AbstractNode : NSObject <Node>

/**
 Determines if the node is currently processing or not.
 */
@property (nonatomic, readonly, getter=isProcessing) BOOL processing;

/**
 @abstract
 Override this method with your Node functionality.
 Call completion block when done.
 */
- (void)onProcess:(void (^)(id result))completion;

@end

NS_ASSUME_NONNULL_END
