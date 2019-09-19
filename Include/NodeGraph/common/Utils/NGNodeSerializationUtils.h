#import <Foundation/Foundation.h>

@protocol NGSerializableNode;

NS_ASSUME_NONNULL_BEGIN

@interface NGNodeSerializationUtils : NSObject

+ (NSDictionary *)serializedRepresentationAsDictionaryFromNode:(id<NGSerializableNode>)node;
+ (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsFromNode:(id<NGSerializableNode>)node
                                                             withNodeMapping:(NSDictionary<NSString *, id<NGSerializableNode>> *)nodeMapping;

@end

NS_ASSUME_NONNULL_END
