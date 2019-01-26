#import <Foundation/Foundation.h>
#import "NodeCombinationType.h"
#import "NodeInput.h"
#import "NodeOutput.h"
#import "NodeOutputCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Node : NSObject

@property (nonatomic, assign) NodeCombinationType combinationType;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NodeInput *> *inputs;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NodeOutputCollection *> *outputs;

- (BOOL)canRun;
- (void)performForInput:(NSString *)inputKey withValue:(id)value;
- (void)ouputValue:(id)value forKey:(NSString *)key;
- (void)distributeToSubNodes;

/**
 Will add @c outputNode as output for all output keys of @c self.
 */
- (void)addOutput:(Node *)output;

/**
 Will add @c outputNode as output for @c key
 */
- (void)addOutput:(Node *)output forKey:(NSString *)key;

    //Add an input: inputs[@"R"] = [NumberTypeInput new];

@end

NS_ASSUME_NONNULL_END
