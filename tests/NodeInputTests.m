#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface NodeInputTests : XCTestCase <NodeInputDelegate, Node>

@property (nonatomic, strong) NodeInput *unNamedInput;
@property (nonatomic, strong) NodeInput *namedInput;
@property (nonatomic, strong) NSNumber *sampleValue;
@property (nonatomic, assign) NSUInteger delegateCallCount;
@property (nonatomic, weak) NodeInput *delegateCaller;
@property (nonatomic, assign) id delegateValue;

@end

@implementation NodeInputTests
// Node Protocol START
@synthesize inputs = _inputs;
@synthesize inputTrigger = _inputTrigger;
@synthesize outputs = _outputs;
- (void)cancel {}
- (void)process {}
// Node Protocol END

- (void)setUp {
    self.unNamedInput = [NodeInput new];
    self.namedInput = [NodeInput inputWithKey:@"test"
                                   validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                         node:self];
    self.sampleValue = @(42);
    self.delegateCallCount = 0;
    self.delegateCaller = nil;
    self.delegateValue = nil;
}

- (void)tearDown {
    
}

#pragma mark - Initialization

- (void)testInit {
    NodeInput *input = [[NodeInput alloc] init];
    XCTAssertNil(input.key);
    XCTAssertNil(input.validationBlock);
    XCTAssertNil(input.node);
}

- (void)testInitWithKey {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NodeInput *input = [[NodeInput alloc] initWithKey:@"test"
                                            validation:validationBlock
                                              node:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertEqual(input.validationBlock, validationBlock);
    XCTAssertEqual(input.node, self);
}

- (void)testStaticNew {
    NodeInput *input = [NodeInput new];
    XCTAssertNil(input.key);
    XCTAssertNil(input.validationBlock);
    XCTAssertNil(input.node);
}

- (void)testStaticInitWithoutValidation {
    NodeInput *input = [NodeInput inputWithKey:@"test" node:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertNil(input.validationBlock);
    XCTAssertEqual(input.node, self);
}

- (void)testStaticInitAll {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NodeInput *input = [NodeInput inputWithKey:@"test" validation:validationBlock node:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertEqual(input.validationBlock, validationBlock);
    XCTAssertEqual(input.node, self);
}

#pragma mark - Validation

- (void)testNilValidationBlockResultsInValidValue {
    XCTAssertTrue([self.unNamedInput valueIsValid:self.sampleValue]);
}

- (void)testNilValidationBlockResultsInValidValueWhenValueIsNil {
    XCTAssertTrue([self.unNamedInput valueIsValid:nil]);
}

- (void)testValidationBlockWithValidValue {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                      node:nil];
    XCTAssertTrue([input valueIsValid:self.sampleValue]);
}

- (void)testValidationBlockWithInvalidValue {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      node:nil];
    XCTAssertFalse([input valueIsValid:self.sampleValue]);
}

#pragma mark - Set Value

- (void)testValueIsSet {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                      node:nil];
    input.value = self.sampleValue;
    XCTAssertEqual(input.value, self.sampleValue);
}

- (void)testValueIsNotSetIfInvalid {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      node:nil];
    input.value = self.sampleValue;
    XCTAssertNil(input.value);
}

#pragma mark - Delegate

- (void)testDelegateIsCalledWhenValueIsSet {
    self.namedInput.value = self.sampleValue;
    XCTAssertEqual(self.delegateCallCount, 1);
    XCTAssertEqual(self.delegateCaller, self.namedInput);
    XCTAssertEqual(self.delegateValue, self.sampleValue);
}

- (void)testDelegateIsCalledWhenNilValueIsSet {
    NodeInput *input = [NodeInput inputWithKey:nil node:self];
    input.value = self.sampleValue;
    input.value = nil;
    XCTAssertEqual(self.delegateCallCount, 2);
    XCTAssertEqual(self.delegateCaller, input);
    XCTAssertNil(self.delegateValue);
}

- (void)testDelegateIsCalledOnceForSameArgumentMultipleTimes {
    self.namedInput.value = self.sampleValue;
    self.namedInput.value = self.sampleValue;
    self.namedInput.value = self.sampleValue;
    self.namedInput.value = self.sampleValue;
    XCTAssertEqual(self.delegateCallCount, 1);
    XCTAssertEqual(self.delegateCaller, self.namedInput);
    XCTAssertEqual(self.delegateValue, self.sampleValue);
}

- (void)testDelegateIsNotCalledWhenValueIsNotValid {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                          node:self];
    input.value = self.sampleValue;
    XCTAssertEqual(self.delegateCallCount, 0);
    XCTAssertNil(self.delegateCaller);
    XCTAssertNil(self.delegateValue);
}

#pragma mark - NodeInputDelegate

- (void)nodeInput:(NodeInput *)nodeInput didUpdateValue:(id)value {
    self.delegateCallCount ++;
    self.delegateCaller = nodeInput;
    self.delegateValue = value;
}

@end
