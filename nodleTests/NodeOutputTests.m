//
//  NodeOutputTests.m
//  NodeOutputTests
//
//  Created by Mikael Sundström on 2019-01-26.
//  Copyright © 2019 Mikael Sundström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface NodeOutputTests : XCTestCase

@property (nonatomic, strong) NodeOutput *unNamedOutput;
@property (nonatomic, strong) NodeOutput *namedOutput;

@end

@implementation NodeOutputTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.unNamedOutput = [NodeOutput new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInit {
    NodeOutput *output = [[NodeOutput alloc] init];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testInitWithKey {
    NodeOutput *output = [[NodeOutput alloc] initWithKey:@"test"];
    XCTAssertNotNil(output.connections);
    XCTAssertEqual(output.key, @"test");
}

- (void)testStaticNew {
    NodeOutput *output = [NodeOutput new];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testStaticInit {
    NodeOutput *output = [NodeOutput output];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testStaticInitWithKey {
    NodeOutput *output = [NodeOutput outputWithKey:@"test"];
    XCTAssertNotNil(output.connections);
    XCTAssertEqual(output.key, @"test");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
