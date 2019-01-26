#import <Foundation/Foundation.h>
#import "NodeCombinationType.h"
#import "NodeInput.h"
#import "NodeOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface Node : NSObject

@property (nonatomic, assign) NodeCombinationType combinationType;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NodeInput *> *inputs;
@property (nonatomic, strong) NSDictionary<NSString *, NSSet<NodeOutput *> *> *outputs;

- (BOOL)canRun;
- (void)performForInput:(NSString *)inputKey withValue:(id)value;
- (void)ouputValue:(id)value forKey:(NSString *)key;
- (void)distributeToSubNodes;

    //Add an input: inputs[@"R"] = [NumberTypeInput new];

@end

NS_ASSUME_NONNULL_END
