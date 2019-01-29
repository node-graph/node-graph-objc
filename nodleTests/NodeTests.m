//
//  nodleTests.m
//  nodleTests
//
//  Created by Mikael Sundström on 2019-01-26.
//  Copyright © 2019 Mikael Sundström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Node.h"

@interface AbstractNode (Tests)

@property (nonatomic, assign, getter=isProcessing) BOOL processing;

@end


@interface NodeTests : XCTestCase

@property (nonatomic, strong) AbstractNode *abstractNode;

@end

@implementation nodleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.abstractNode = [AbstractNode new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
