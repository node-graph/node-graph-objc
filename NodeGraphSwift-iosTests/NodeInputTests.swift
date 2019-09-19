//
//  NodeInputTests.swift
//  NodeGraphSwift-iosTests
//
//  Created by Mikael Sundström on 2019-09-13.
//  Copyright © 2019 NodeGraph. All rights reserved.
//

import XCTest
@testable import NodeGraphSwift_ios

class _NodeInputTestMockNode: AbstractNode {
    var delegateCallCount: NSInteger
    var delegateCaller: NodeInput? = nil
    var delegateValue: AnyHashable? = nil
    
    override init() {
        delegateCallCount = 0
    }
    
    override func nodeInputDidUpdateValue(_ nodeInput: NodeInput, value: AnyHashable?) {
        delegateCallCount += 1
        delegateCaller = nodeInput
        delegateValue = value
    }
}

class NodeInputTests: XCTestCase {
    var unNamedInput: NodeInput!
    var namedInput: NodeInput!
    var sampleValue: NSNumber!
    var mockNode: _NodeInputTestMockNode!
    
    override func setUp() {
        unNamedInput = NodeInput()
        mockNode = _NodeInputTestMockNode()
        sampleValue = NSNumber(42)
        namedInput = NodeInput(withKey: "testKey", forNode: mockNode, withValidationBlock: { (value) -> Bool in
            guard let _ = value as? NSNumber else {
                return false
            }
            return true
        })
    }
    
    func test_init() {
        let input = NodeInput()
        XCTAssertNil(input.key)
        XCTAssertNil(input.validationBlock)
        XCTAssertNil(input.node)
    }
    
    func test_initWithKey() {
        let validationBlock: (_: AnyHashable?) -> Bool = { _ in return true }
        let input = NodeInput(withKey: "testKey",
                              forNode: mockNode,
                              withValidationBlock: validationBlock)
        XCTAssertEqual(input.key, "testKey")
        
        //NOTE: Not comparable in swift
        //XCTAssertEqual(input.validationBlock!, validationBlock)
        //XCTAssertEqual(input.node!, mockNode)
    }
    
    // MARK: Validation
    func test_nilValidationBlockResultsInValidValue() {
        XCTAssertTrue(unNamedInput.valueIsValid(sampleValue))
    }
    
    func test_nilValidationBlockResultsinValidValueWhenValueIsNil() {
        XCTAssertTrue(unNamedInput.valueIsValid(nil))
    }
    
    func test_validationBlockWithValidValue() {
        let input = NodeInput(withKey: nil, forNode: nil) { (value) -> Bool in
            guard let _ = value as? NSNumber else {
                return false
            }
            return true
        }
        
        XCTAssertTrue(input.valueIsValid(sampleValue))
    }
    
    func test_validationBlockWithInvalidValue() {
        let input = NodeInput(withKey: nil, forNode: nil) { (value) -> Bool in
            guard let _ = value as? String else {
                return false
            }
            return true
        }
        
        XCTAssertFalse(input.valueIsValid(sampleValue))
    }
    
    // MARK: Set value
    func test_valueIsSet() {
        let input = NodeInput(withKey: nil, forNode: nil) { (value) -> Bool in
            guard let _ = value as? NSNumber else {
                return false
            }
            return true
        }
        
        input.value = sampleValue
        XCTAssertEqual(input.value, sampleValue)
    }
    
    func testvalueIsNotSetIfInvalid() {
        let input = NodeInput(withKey: nil, forNode: nil) { (value) -> Bool in
            guard let _ = value as? String else {
                return false
            }
            return true
        }
        
        input.value = sampleValue
        XCTAssertNil(input.value)
    }
    
    // MARK: Delegate
    func test_delegateIsCalledWhenValueIsSet() {
        namedInput.value = sampleValue
        XCTAssertEqual(mockNode.delegateCallCount, 1)
        XCTAssertEqual(mockNode.delegateCaller, namedInput)
        XCTAssertEqual(mockNode.delegateValue, sampleValue)
    }
    
    func test_delegateIsCalledWhenNilValueIsSet() {
        let input = NodeInput(withKey: nil, forNode: mockNode)
        input.value = sampleValue
        input.value = nil
        XCTAssertEqual(mockNode.delegateCallCount, 2)
        XCTAssertEqual(mockNode.delegateCaller, input)
        XCTAssertNil(mockNode.delegateValue)
    }
    
    func test_delegateIsCalledOnceForSameArgumentMultipleTimes() {
        namedInput.value = sampleValue
        namedInput.value = sampleValue
        namedInput.value = sampleValue
        namedInput.value = sampleValue
        XCTAssertEqual(mockNode.delegateCallCount, 1)
        XCTAssertEqual(mockNode.delegateCaller, namedInput)
        XCTAssertEqual(mockNode.delegateValue, sampleValue)
    }
    
    func test_delegateIsNotCalledWhenValueIsNotValid() {
        let input = NodeInput(withKey: nil, forNode: nil) { (value) -> Bool in
            guard let _ = value as? String else {
                return false
            }
            return true
        }
        input.value = sampleValue
        XCTAssertEqual(mockNode.delegateCallCount, 0)
        XCTAssertNil(mockNode.delegateCaller)
        XCTAssertNil(mockNode.delegateValue)
    }
    
    // MARK: Equatable and hashable sanity
    func test_equalityOfSameInput() {
        let input = NodeInput(withKey: nil, forNode: nil)
        XCTAssertEqual(input, input)
    }
    
    func test_equalityOfDifferentInputs() {
        let input1 = NodeInput(withKey: nil, forNode: nil)
        let input2 = NodeInput(withKey: nil, forNode: nil)
        XCTAssertNotEqual(input1, input2)
    }
    
    func test_hashableWithNilValues() {
        let input1 = NodeInput(withKey: nil, forNode: nil)
        let input2 = NodeInput(withKey: nil, forNode: nil)
        
        var testSet = Set<NodeInput>()
        testSet.insert(input1)
        testSet.insert(input2)
        
        XCTAssertEqual(testSet.count, 2)
    }
    
    func test_hashableWithValues() {
        let input1 = NodeInput(withKey: "TestKey", forNode: mockNode)
        let input2 = NodeInput(withKey: "TestKey", forNode: mockNode)
        
        var testSet = Set<NodeInput>()
        testSet.insert(input1)
        testSet.insert(input2)
        
        XCTAssertEqual(testSet.count, 2)
    }
}
