#import <Foundation/Foundation.h>

@protocol SerializableNode;

NS_ASSUME_NONNULL_BEGIN

@interface NodeSerializationUtils : NSObject

+ (NSDictionary *)serializedRepresentationAsDictionaryFromNode:(id<SerializableNode>)node;
+ (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsFromNode:(id<SerializableNode>)node
                                                             withNodeMapping:(NSDictionary<NSString *, id<SerializableNode>> *)nodeMapping;

@end

NS_ASSUME_NONNULL_END
