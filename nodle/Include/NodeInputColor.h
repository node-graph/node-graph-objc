//
//  NodeInputColor.h
//  nodle
//
//  Created by Patrik Nyblad on 2019-01-29.
//  Copyright © 2019 Mikael Sundström. All rights reserved.
//

#import <nodle/nodle.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeInputColor : NodeInput

@property (nonatomic, strong, nullable) UIColor *value;

- (instancetype)initWithKey:(nullable NSString *)key
                   delegate:(nullable id<NodeInputDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
