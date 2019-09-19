#import <XCTest/XCTest.h>
#import <NodeGraph/NodeGraph.h>

@interface NGNodeInputTests : XCTestCase <NGNodeInputDelegate, NGNode>

@property (nonatomic, strong) NGNodeInput *unNamedInput;
@property (nonatomic, strong) NGNodeInput *namedInput;
@property (nonatomic, strong) NSNumber *sampleValue;
@property (nonatomic, assign) NSUInteger delegateCallCount;
@property (nonatomic, weak) NGNodeInput *delegateCaller;
@property (nonatomic, assign) id delegateValue;

@end

@implementation NGNodeInputTests
// Node Protocol START
@synthesize inputs = _inputs;
@synthesize inputTrigger = _inputTrigger;
@synthesize outputs = _outputs;
- (void)cancel {}
- (void)process {}
// Node Protocol END

- (void)setUp {
    self.unNamedInput = [NGNodeInput new];
    self.namedInput = [NGNodeInput inputWithKey:@"test"
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
    NGNodeInput *input = [[NGNodeInput alloc] init];
    XCTAssertNil(input.key);
    XCTAssertNil(input.validationBlock);
    XCTAssertNil(input.node);
}

- (void)testInitWithKey {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NGNodeInput *input = [[NGNodeInput alloc] initWithKey:@"test"
                                            validation:validationBlock
                                              node:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertEqual(input.validationBlock, validationBlock);
    XCTAssertEqual(input.node, self);
}

- (void)testStaticNew {
    NGNodeInput *input = [NGNodeInput new];
    XCTAssertNil(input.key);
    XCTAssertNil(input.validationBlock);
    XCTAssertNil(input.node);
}

- (void)testStaticInitWithoutValidation {
    NGNodeInput *input = [NGNodeInput inputWithKey:@"test" node:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertNil(input.validationBlock);
    XCTAssertEqual(input.node, self);
}

- (void)testStaticInitAll {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NGNodeInput *input = [NGNodeInput inputWithKey:@"test" validation:validationBlock node:self];
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
    NGNodeInput *input = [NGNodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                      node:nil];
    XCTAssertTrue([input valueIsValid:self.sampleValue]);
}

- (void)testValidationBlockWithInvalidValue {
    NGNodeInput *input = [NGNodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      node:nil];
    XCTAssertFalse([input valueIsValid:self.sampleValue]);
}

#pragma mark - Set Value

- (void)testValueIsSet {
    NGNodeInput *input = [NGNodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                      node:nil];
    input.value = self.sampleValue;
    XCTAssertEqual(input.value, self.sampleValue);
}

- (void)testValueIsNotSetIfInvalid {
    NGNodeInput *input = [NGNodeInput inputWithKey:nil
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
    NGNodeInput *input = [NGNodeInput inputWithKey:nil node:self];
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
    NGNodeInput *input = [NGNodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                          node:self];
    input.value = self.sampleValue;
    XCTAssertEqual(self.delegateCallCount, 0);
    XCTAssertNil(self.delegateCaller);
    XCTAssertNil(self.delegateValue);
}

#pragma mark - NGNodeInputDelegate

- (void)nodeInput:(NGNodeInput *)nodeInput didUpdateValue:(id)value {
    self.delegateCallCount ++;
    self.delegateCaller = nodeInput;
    self.delegateValue = value;
}

@end
