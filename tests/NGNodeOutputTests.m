#import <XCTest/XCTest.h>
#import <NodeGraph/NodeGraph.h>

@interface NGNodeOutputTests : XCTestCase

@property (nonatomic, strong) NGNodeOutput *unNamedOutput;
@property (nonatomic, strong) NGNodeOutput *namedOutput;
@property (nonatomic, strong) NSNumber *sampleResult;

@end

@implementation NGNodeOutputTests

- (void)setUp {
    self.unNamedOutput = [NGNodeOutput output];
    self.namedOutput = [NGNodeOutput outputWithKey:@"test"];
    self.sampleResult = @(42);
}

- (void)tearDown {

}

#pragma mark - Initialization

- (void)testInit {
    NGNodeOutput *output = [[NGNodeOutput alloc] init];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testInitWithKey {
    NGNodeOutput *output = [[NGNodeOutput alloc] initWithKey:@"test"];
    XCTAssertNotNil(output.connections);
    XCTAssertEqual(output.key, @"test");
}

- (void)testStaticNew {
    NGNodeOutput *output = [NGNodeOutput new];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testStaticInit {
    NGNodeOutput *output = [NGNodeOutput output];
    XCTAssertNotNil(output.connections);
    XCTAssertNil(output.key);
}

- (void)testStaticInitWithKey {
    NGNodeOutput *output = [NGNodeOutput outputWithKey:@"test"];
    XCTAssertNotNil(output.connections);
    XCTAssertEqual(output.key, @"test");
}

#pragma mark - Connections

- (void)testAddingConnection {
    NGNodeInput *connection = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection];
    XCTAssertEqual(self.unNamedOutput.connections.count, 1);
    XCTAssertEqual(connection, [self.unNamedOutput.connections anyObject]);
}

- (void)testAddingSameConnectionTwiceOnlyStoresOne {
    NGNodeInput *connection = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput addConnection:connection];
    XCTAssertEqual(self.unNamedOutput.connections.count, 1);
    XCTAssertEqual(connection, [self.unNamedOutput.connections anyObject]);
}

- (void)testRemovingConnection {
    NGNodeInput *connection = [NGNodeInput new];
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
    
    NGNodeInput *connection = [NGNodeInput new];
    __weak NGNodeInput *weakConnection = connection; // Control variable
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
    NGNodeInput *connection = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput sendResult:self.sampleResult];
    XCTAssertEqual(connection.value, self.sampleResult);
}

- (void)testSendingNilResultToSingleConnection {
    NGNodeInput *connection = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection];
    [self.unNamedOutput sendResult:self.sampleResult];
    [self.unNamedOutput sendResult:nil];
    XCTAssertNil(connection.value);
}

- (void)testSendingResultToMultipleConnections {
    NGNodeInput *connection1 = [NGNodeInput new];
    NGNodeInput *connection2 = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection1];
    [self.unNamedOutput addConnection:connection2];
    [self.unNamedOutput sendResult:self.sampleResult];
    XCTAssertEqual(connection1.value, self.sampleResult);
    XCTAssertEqual(connection2.value, self.sampleResult);
}

- (void)testSendingNilResultToMultipleConnections {
    NGNodeInput *connection1 = [NGNodeInput new];
    NGNodeInput *connection2 = [NGNodeInput new];
    [self.unNamedOutput addConnection:connection1];
    [self.unNamedOutput addConnection:connection2];
    [self.unNamedOutput sendResult:self.sampleResult];
    [self.unNamedOutput sendResult:nil];
    XCTAssertNil(connection1.value);
    XCTAssertNil(connection2.value);
}

@end
