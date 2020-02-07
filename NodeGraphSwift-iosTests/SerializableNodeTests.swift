//
//  SerializableNodeTests.swift
//  NodeGraphSwift-iosTests
//
//  Created by Mikael Sundström on 2019-10-03.
//  Copyright © 2019 NodeGraph. All rights reserved.
//

import XCTest
@testable import NodeGraphSwift_ios

class _SerializableTestNode: AbstractNode {
    override init() {
        
        super.init()

        let output = NodeOutput(withKey: "TestOutput")
        let input = NodeInput(withKey: "TestInput", forNode: self)
        
        inputs.insert(input)
        outputs.insert(output)
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class SerializableNodeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let node = _SerializableTestNode()
        node.nodeName = "_SerializableTestNode --- asd"
        node.nodeDescription = "_SerializableTestNode description"
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let jsonData = try! jsonEncoder.encode(node)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString!)
    }
}
