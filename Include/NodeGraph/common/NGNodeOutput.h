#import <Foundation/Foundation.h>

@class NGNodeInput;

NS_ASSUME_NONNULL_BEGIN

/**
 A representation of an output from a Node. An output can be named with a key to
 signify what part of the result it carries.
 
 An output has connections as weak references to instances of NGNodeInput.
 */
@interface NGNodeOutput: NSObject

/**
 The key of this output, can be nil if the node only has one output.
 An example value for this could be the `R` output key in an `RGB` node.
 */
@property (nonatomic, strong, nullable, readonly) NSString *key;

/**
 The downstream node inputs that gets the result of this output.
 @warning Please do not mutate this object directly.
 */
@property (nonatomic, strong, readonly) NSHashTable<NGNodeInput *> *connections;

/**
 Creates an output with a key/name.
 */
+ (instancetype)outputWithKey:(NSString *)key;

/**
 Creates an output without a key.
 */
+ (instancetype)output;

/**
 Creates an output with a key/name.
 */
- (instancetype)initWithKey:(NSString *)key;

/**
 Adds a downstream connection from this output.
 */
- (void)addConnection:(NGNodeInput *)connection;

/**
 Removes a downstream connection from this output.
 */
- (void)removeConnection:(NGNodeInput *)connection;

/**
 Sends the result to each connection.
 */
- (void)sendResult:(nullable id)result;

@end

NS_ASSUME_NONNULL_END
