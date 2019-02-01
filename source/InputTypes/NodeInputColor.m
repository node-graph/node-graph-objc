//
//  NodeInputColor.m
//  nodle
//
//  Created by Patrik Nyblad on 2019-01-29.
//  Copyright © 2019 Mikael Sundström. All rights reserved.
//

#import "NodeInputColor.h"

@implementation NodeInputColor

- (instancetype)initWithKey:(NSString *)key delegate:(id<NodeInputDelegate>)delegate {
    self = [self initWithKey:key
                  validation:^BOOL(id  _Nonnull value) {return [value isKindOfClass:[UIColor class]];}
                    delegate:delegate];
    return self;
}

@end
