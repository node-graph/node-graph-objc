#import <Foundation/Foundation.h>
#import "NodeOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface NodeOutputCollection : NSObject

@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableSet<Node *> *outputs;

- (instancetype)initWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
