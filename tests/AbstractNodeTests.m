#import <XCTest/XCTest.h>
#import <NodeGraph/NodeGraph.h>

@interface DeferredTestNode : AbstractNode
@property (nonatomic, copy) void (^processed)(void);
@property (nonatomic, copy) void (^canceled)(void);
@property (nonatomic, strong) NodeInput *aInput;
@property (nonatomic, strong) NodeInput *bInput;
@property (nonatomic, strong) NodeOutput *aOutput;
@property (nonatomic, assign) BOOL deferred;
@end
@implementation DeferredTestNode
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;
- (instancetype)init {
    self = [super init];
    if (self) {
        // Having two inputs and trigger on any (default) should make the processing use the deferred pipeline
        _aInput = [[NodeInput alloc] initWithKey:@"a" validation:nil node:self];
        _bInput = [[NodeInput alloc] initWithKey:@"b" validation:nil node:self];
        _inputs = [NSSet setWithObjects:_aInput, _bInput, nil];
        _aOutput = [NodeOutput outputWithKey:@"a"];
        _outputs = [NSSet setWithObjects:_aOutput, nil];
        _deferred = YES;
    }
    return self;
}
- (void)doProcess:(void (^)(void))completion {
    completion();
    if (self.processed)
        self.processed();
}
- (BOOL)useDeferredProcessing {
    return self.deferred;
}
- (void)cancel {
    [super cancel];
    if (self.canceled)
        self.canceled();
}
@end

@interface AbstractNodeTests : XCTestCase

@property (nonatomic, strong) AbstractNode *abstractNode;
@property (nonatomic, strong) DeferredTestNode *deferredTestNode;
@property (nonatomic, assign) NSUInteger performanceIterations;

@end

@implementation AbstractNodeTests

- (void)setUp {
    self.abstractNode = [AbstractNode new];
    self.deferredTestNode = [DeferredTestNode new];
    self.performanceIterations = 10000;
}

- (void)tearDown {

}

#pragma mark - Input to Output

- (void)testInputTriggersProcessingToOutputToConnections {
    NodeInput *connection = [NodeInput new];
    NSNumber *value = @(42);
    [[self.abstractNode.outputs anyObject] addConnection:connection];
    [[self.abstractNode.inputs anyObject] setValue:value];
    XCTAssertEqual(connection.value, value);
}

#pragma mark - Cancel

- (void)testCancelOperationForwardsCancelRecursively {
    __block BOOL cancelCalled = NO;
    self.deferredTestNode.canceled = ^{
        cancelCalled = YES;
    };
    [[self.abstractNode.outputs anyObject] addConnection:self.deferredTestNode.aInput];
    [self.abstractNode cancel];
    XCTAssertTrue(cancelCalled);
}

- (void)testCancelOperationInCircularNodeGraphsDoesNotTriggerInfiniteLoop {
    __block NSUInteger cancelCallCount = NO;
    self.deferredTestNode.canceled = ^{
        cancelCallCount ++;
    };
    [[self.abstractNode.outputs anyObject] addConnection:self.deferredTestNode.aInput];
    [self.deferredTestNode.aOutput addConnection:[self.abstractNode.inputs anyObject]];
    [self.abstractNode cancel];
    XCTAssertEqual(cancelCallCount, 1);
}

#pragma mark - Deferred Processing

- (void)testDirectProcessingPerformance {
    XCTestExpectation *measureExpectation = [self expectationWithDescription:@"measure time"];
    
    [self measureBlock:^(void (^completion)(void)) {
        [self.abstractNode process];
        completion();
    } iterations:self.performanceIterations completion:^(NSTimeInterval time) {
        NSLog(@"Direct ProcessingPerformance TotalMs: %f AverageMs: %f Iterations: %lu", time*1000, (time*1000)/self.performanceIterations, (unsigned long)self.performanceIterations);
        [measureExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDeferredProcessingPerformance {
    XCTestExpectation *measureExpectation = [self expectationWithDescription:@"measure time"];
    
    [self measureBlock:^(void (^completion)(void)) {
        self.deferredTestNode.processed = ^(){
            completion();
        };
        [self.deferredTestNode process];
    } iterations:10000 completion:^(NSTimeInterval time) {
        NSLog(@"Deferred ProcessingPerformance TotalMs: %f AverageMs: %f Iterations: %lu", time*1000, (time*1000)/self.performanceIterations, (unsigned long)self.performanceIterations);
        [measureExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testAllArgumentsAreSetBeforeDeferredProcessing {
    XCTestExpectation *argumentsExpectation = [self expectationWithDescription:@"Both arguments set"];

    // Expected input values
    NSNumber *arg1 = @(58);
    NSNumber *arg2 = @(42);
    
    // Setting a value triggers processing
    self.deferredTestNode.aInput.value = arg1;
    
    // Processing should be deferred and both values are available
    self.deferredTestNode.processed = ^{
        XCTAssertEqual(self.deferredTestNode.aInput.value, arg1);
        XCTAssertEqual(self.deferredTestNode.bInput.value, arg2);
        [argumentsExpectation fulfill];
    };
    
    // Set other value
    self.deferredTestNode.bInput.value = arg2;
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testDirectProcessingTriggersOnFirstArgumentSet {
    // Expected input values
    NSNumber *arg1 = @(58);
    NSNumber *arg2 = @(42);
    
    // Processing should be deferred and both values are available
    __block NSUInteger triggerCount = 0;
    self.deferredTestNode.deferred = NO;
    self.deferredTestNode.processed = ^{
        XCTAssertEqual(self.deferredTestNode.aInput.value, arg1);
        if (triggerCount == 0) {
            XCTAssertNil(self.deferredTestNode.bInput.value);
        }
        triggerCount ++;
    };
    
    // Setting a value triggers processing
    self.deferredTestNode.aInput.value = arg1;
    self.deferredTestNode.bInput.value = arg2;
    XCTAssertEqual(triggerCount, 2);
}

#pragma mark - Helpers

- (void)measureBlock:(void(^)(void(^completion)(void)))block
          iterations:(NSUInteger)iterations
          completion:(void(^)(NSTimeInterval time))completion {
    __block int i = 0;
    __block NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    __block NSTimeInterval testTime = 0;
    __block void(^iterator)(void) = nil;
    iterator = ^(){
        i++;
        block(^(){
            if (i < iterations) {
                iterator();
            } else {
                testTime = [[NSDate date] timeIntervalSince1970] - start;
                completion(testTime);
            }
        });
    };
    iterator();
}

@end
