//
//  AbstractNodeTests.m
//  nodleTests
//
//  Created by Patrik Nyblad on 2019-01-30.
//  Copyright © 2019 Mikael Sundström. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface DeferredTestNode : AbstractNode
@property (nonatomic, copy) void (^processed)(void);
@end
@implementation DeferredTestNode
@synthesize inputs = _inputs;
- (instancetype)init {
    self = [super init];
    if (self) {
        // Having two inputs and trigger on any (default) should make the processing use the deferred pipeline
        _inputs = [NSSet setWithObjects:
                   [[NodeInput alloc] initWithKey:@"a" validation:nil delegate:self],
                   [[NodeInput alloc] initWithKey:@"b" validation:nil delegate:self], nil];
    }
    return self;
}

- (void)doProcess:(void (^)(void))completion {
    completion();
    self.processed();
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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
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
