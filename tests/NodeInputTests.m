#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface NodeInputTests : XCTestCase <NodeInputDelegate>

@property (nonatomic, strong) NodeInput *unNamedInput;
@property (nonatomic, strong) NodeInput *namedInput;
@property (nonatomic, strong) NSNumber *sampleValue;
@property (nonatomic, assign) BOOL delegateCalled;
@property (nonatomic, weak) NodeInput *delegateCaller;
@property (nonatomic, assign) id delegateValue;

@end

@implementation NodeInputTests

- (void)setUp {
    self.unNamedInput = [NodeInput new];
    self.namedInput = [NodeInput inputWithKey:@"test"
                                   validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                     delegate:self];
    self.sampleValue = @(42);
    self.delegateCalled = NO;
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
    XCTAssertNil(input.delegate);
}

- (void)testInitWithKey {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NodeInput *input = [[NodeInput alloc] initWithKey:@"test"
                                            validation:validationBlock
                                              delegate:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertEqual(input.validationBlock, validationBlock);
    XCTAssertEqual(input.delegate, self);
}

- (void)testStaticNew {
    NodeInput *input = [NodeInput new];
    XCTAssertNil(input.key);
    XCTAssertNil(input.validationBlock);
    XCTAssertNil(input.delegate);}

- (void)testStaticInitWithoutValidation {
    NodeInput *input = [NodeInput inputWithKey:@"test" delegate:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertNil(input.validationBlock);
    XCTAssertEqual(input.delegate, self);
}

- (void)testStaticInitAll {
    BOOL (^validationBlock)(id _Nonnull value) = ^BOOL(id _Nonnull value) {return YES;};
    NodeInput *input = [NodeInput inputWithKey:@"test" validation:validationBlock delegate:self];
    XCTAssertEqual(input.key, @"test");
    XCTAssertEqual(input.validationBlock, validationBlock);
    XCTAssertEqual(input.delegate, self);
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
                                      delegate:nil];
    XCTAssertTrue([input valueIsValid:self.sampleValue]);
}

- (void)testValidationBlockWithInvalidValue {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      delegate:nil];
    XCTAssertFalse([input valueIsValid:self.sampleValue]);
}

#pragma mark - Set Value

- (void)testValueIsSet {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSNumber class]];}
                                      delegate:nil];
    input.value = self.sampleValue;
    XCTAssertEqual(input.value, self.sampleValue);
}

- (void)testValueIsNotSetIfInvalid {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      delegate:nil];
    input.value = self.sampleValue;
    XCTAssertNil(input.value);
}

#pragma mark - Delegate

- (void)testDelegateIsCalledWhenValueIsSet {
    self.namedInput.value = self.sampleValue;
    XCTAssertTrue(self.delegateCalled);
    XCTAssertEqual(self.delegateCaller, self.namedInput);
    XCTAssertEqual(self.delegateValue, self.sampleValue);
}

- (void)testDelegateIsCalledWhenNilValueIsSet {
    NodeInput *input = [NodeInput inputWithKey:nil delegate:self];
    input.value = nil;
    XCTAssertTrue(self.delegateCalled);
    XCTAssertEqual(self.delegateCaller, input);
    XCTAssertNil(self.delegateValue);
}

- (void)testDelegateIsNotCalledWhenValueIsNotValid {
    NodeInput *input = [NodeInput inputWithKey:nil
                                    validation:^BOOL(id  _Nullable value) {return [value isKindOfClass:[NSString class]];}
                                      delegate:self];
    input.value = self.sampleValue;
    XCTAssertFalse(self.delegateCalled);
    XCTAssertNil(self.delegateCaller);
    XCTAssertNil(self.delegateValue);
}

#pragma mark - NodeInputDelegate

- (void)nodeInput:(NodeInput *)nodeInput didUpdateValue:(id)value {
    self.delegateCalled = YES;
    self.delegateCaller = nodeInput;
    self.delegateValue = value;
}

@end
