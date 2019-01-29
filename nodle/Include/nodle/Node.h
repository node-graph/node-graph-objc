#import <Foundation/Foundation.h>
#import "NodeInput.h"
#import "NodeOutput.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Decides what inputs need to be set in order for a node to process.
 */
typedef NS_ENUM(NSUInteger, NodeInputTrigger) {
    /// The node does not automatically process anything, you manually have to call the -process method.
    NodeInputTriggerNoAutomaticProcessing,
    /// Process as soon as any input is set.
    NodeInputTriggerAny,
    /// All inputs have to be triggered between each run for the node to process.
    NodeInputTriggerAll,
    /// Same as NodeInputRequirementAll but keeps the value so next run can start whenever any input is set.
    NodeInputTriggerAllAtLeastOnce,
    /// The processing behaviour is custom and driven by the node itself.
    NodeInputTriggerCustom
};


/**
 A Node in Nodle can have multiple input types but only one type of output.
 
 Let't take an Add Node as the simplest example. It would require at least two inputs but the
 result would only be one value. Downstream nodes can be specified in the outputs property
 however but they all receive the same result.

 
 Node example:
 
  20         4
   \        /
  --A------B--
 |            |
 |   Divide   |
 |  O = A / B |
 |            |
  ------O-----
        |
        5
 
 */
@protocol Node
@required

/**
 Specifies what inputs need to be set in order for the node to process.
 */
@property (nonatomic, assign, readonly) NodeInputTrigger inputTrigger;

/**
 The inputs of this node, inputs do not reference upstream nodes but keeps a result from an upstream node
 that this node can use when -process is called.
 */
@property (nonatomic, strong, readonly) NSSet<NodeInput *> *inputs;

/**
 All downstream connections out from this node. When -process is run the result will be fed to each NodeOutput.
 */
@property (nonatomic, strong, readonly) NSSet<NodeOutput *> *outputs;

/**
 Processes the node with the current values stored in the inputs of this node.
 All outputs will be triggered with the result of this nodes operation.
 
 This method will also be triggered internally based on the inputTrigger specified by the node.
 */
- (void)process;

/**
 Cancels the current processing and stops the result from flowing to any downstream nodes.
 */
- (void)cancel;

@end


/**
 Abstract class that you should subclass and implement in order to have a functioning Node.
 
 Methods to override:
 -process
 */
@interface AbstractNode : NSObject <Node, NodeInputDelegate>

/**
 Determines if the node is currently processing or not.
 */
@property (nonatomic, readonly, getter=isProcessing) BOOL processing;

/**
 @abstract
 Implement this method with your Node functionality.
 1, Process input values
 2, Send result to each respective output
 3, Call completion block when done
 */
- (void)doProcess:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
