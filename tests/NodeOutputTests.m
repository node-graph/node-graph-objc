#import <XCTest/XCTest.h>
#import <NodeGraph/NodeGraph.h>

@interface NodeOutputTests : XCTestCase

@property (nonatomic, strong) NodeOutput *unNamedOutput;
@property (nonatomic, strong) NodeOutput *namedOutput;
@property (nonatomic, strong) NSNumber *sampleResult;

@end

@implementation NodeOutputTests

- (void)setUp {
    self.unNamedOutput = [NodeOutput output];
    self.namedOutput = [NodeOutput outputWithKey:@"test"];
    self.sampleResult = @(42);
}

- (void)tearDown {

}

#pragma mark - Initialization

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

#pragma mark - Connections

- (void)testAddingConnection {
    NodeInput *connection = [NodeInput new];
    [self.unNamedOutput addConnection:connection];
    XCTAssertEqual(self.unNamedOutput.connections.count, 1);
    XCTAssertEqual(connection, [self.unNamedOutput.connections anyObject]);
}

- (void)testAddingSameConnectionTwiceOnlyStoresOne {
    NodeInput *connection = [NodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput addConnection:connection];
    XCTAssertEqual(self.unNamedOutput.connections.count, 1);
    XCTAssertEqual(connection, [self.unNamedOutput.connections anyObject]);
}

- (void)testRemovingConnection {
    NodeInput *connection = [NodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput removeConnection:connection];
    XCTAssertEqual(self.unNamedOutput.connections.count, 0);
}

- (void)testConnectionIsRemovedWhenConnectionIsDeallocated {
    /**
     When doing this test it is really important not to make another
     reference to the `connection` variable by mistake. You could easily
     make this mistake by using the `-anyObject` method on
     `self.unNamedOutput.connections`. That is why we only reference the
     count and not any object collections or references.
     */
    
    NodeInput *connection = [NodeInput new];
    __weak NodeInput *weakConnection = connection; // Control variable
    [self.unNamedOutput addConnection:connection]; // Connection is added
    XCTAssertEqual(self.unNamedOutput.connections.count, 1); // Check without referencing the connection instance
    connection = nil; // Deallocate the object
    XCTAssertNil(weakConnection, @"Something wrong with test, are you referencing the connection that accidentally stops it from being deallocated when connection is set to nil?"); // Check that the control was properly deallocated
    XCTAssertEqual(self.unNamedOutput.connections.allObjects.count, 0);
    XCTAssertNil([self.unNamedOutput.connections anyObject]);
}

#pragma mark - Send Result

- (void)testSendingResultToNoConnectionsDoesNotCrash {
    [self.unNamedOutput sendResult:nil];
}

- (void)testSendingNilResultToNoConnectionsDoesNotCrash {
    [self.unNamedOutput sendResult:self.sampleResult];
}

- (void)testSendingResultToSingleConnection {
    NodeInput *connection = [NodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput sendResult:self.sampleResult];
    XCTAssertEqual(connection.value, self.sampleResult);
}

- (void)testSendingNilResultToSingleConnection {
    NodeInput *connection = [NodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput sendResult:self.sampleResult];
    [self.unNamedOutput sendResult:nil];
    XCTAssertNil(connection.value);
}

- (void)testSendingResultToMultipleConnections {
    NodeInput *connection1 = [NodeInput new];
    NodeInput *connection2 = [NodeInput new];
    [self.unNamedOutput addConnection:connection1];
    [self.unNamedOutput addConnection:connection2];
    [self.unNamedOutput sendResult:self.sampleResult];
    XCTAssertEqual(connection1.value, self.sampleResult);
    XCTAssertEqual(connection2.value, self.sampleResult);
}

- (void)testSendingNilResultToMultipleConnections {
    NodeInput *connection1 = [NodeInput new];
    NodeInput *connection2 = [NodeInput new];
    [self.unNamedOutput addConnection:connection1];
    [self.unNamedOutput addConnection:connection2];
    [self.unNamedOutput sendResult:self.sampleResult];
    [self.unNamedOutput sendResult:nil];
    XCTAssertNil(connection1.value);
    XCTAssertNil(connection2.value);
}

@end
