//
//  NodeOutputTests.swift
//  NodeGraphSwift-iosTests
//
//  Created by Mikael Sundström on 2019-09-13.
//  Copyright © 2019 NodeGraph. All rights reserved.
//

import XCTest
@testable import NodeGraphSwift_ios

class NodeOutputTests: XCTestCase {
    
    var unNamedOutput: NodeOutput!
    var namedOutput: NodeOutput!
    var sampleResult: NSNumber!

    override func setUp() {
        unNamedOutput = NodeOutput()
        namedOutput = NodeOutput(withKey: "testKey")
        sampleResult = NSNumber(value: 42)
    }

    //Mark: Inits
    func test_init() {
        let output = NodeOutput()
        
        XCTAssertNotNil(output.connections)
        XCTAssertNil(output.key)
    }
    
    func test_initWithKey() {
        let output = NodeOutput(withKey: "testKey")
        
        XCTAssertNotNil(output.connections)
        XCTAssertEqual(output.key, "testKey")
    }
    
    //Mark: Connections
    func test_addingConnection() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection)
        
        XCTAssertEqual(unNamedOutput.connections.count, 1)
        XCTAssertEqual(connection, unNamedOutput.connections.anyObject)
    }
    
    func test_addingSameConnectionTwiceOnlyStoreOne() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection)
        unNamedOutput.addConnection(nodeInput: connection)
        
        XCTAssertEqual(unNamedOutput.connections.count, 1)
        XCTAssertEqual(connection, unNamedOutput.connections.anyObject)
    }
    
    func test_removingConnection() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection)
        unNamedOutput.removeConnection(nodeInput: connection)
        
        XCTAssertEqual(unNamedOutput.connections.count, 0)
    }
    
    func test_connectionIsRemovedWhenConnectionIsDeallocated() {
        var connection: NodeInput? = NodeInput(withKey: nil, forNode: nil)
        weak var weakConnection = connection
        unNamedOutput.addConnection(nodeInput: connection!)
        XCTAssertEqual(unNamedOutput.connections.count, 1)
        
        connection = nil
        
        XCTAssertNil(weakConnection, "Something wrong with test, are you referencing the connection that accidentally stops it from being deallocated when connection is set to nil?")
        
        XCTAssertEqual(unNamedOutput.connections.allObjects.count, 0)
        XCTAssertNil(unNamedOutput.connections.anyObject)
        
    }
    
    //MARK: Send results
    func test_sendingResultToNoConnectionDoesNotCrash() {
        unNamedOutput.send(result: nil)
    }
    
    func test_sendingResultToNoConnectionsDoesNotCrash() {
        unNamedOutput.send(result: sampleResult)
    }
    
    func test_sendingResultToSingleConnection() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection)
        unNamedOutput.send(result: sampleResult)
        XCTAssertEqual(connection.value, sampleResult)
    }
    
    func test_sendingNilResultToSingleConnection() {
        let connection = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection)
        unNamedOutput.send(result: nil)
        XCTAssertNil(connection.value)
    }
    
    func test_sendingResultToMultipleConnections() {
        let connection1 = NodeInput(withKey: nil, forNode: nil)
        let connection2 = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection1)
        unNamedOutput.addConnection(nodeInput: connection2)
        unNamedOutput.send(result: sampleResult)
        XCTAssertEqual(connection1.value, sampleResult)
        XCTAssertEqual(connection2.value, sampleResult)
    }
    
    func test_sendingNilResultToMultipleConnections() {
        let connection1 = NodeInput(withKey: nil, forNode: nil)
        let connection2 = NodeInput(withKey: nil, forNode: nil)
        unNamedOutput.addConnection(nodeInput: connection1)
        unNamedOutput.addConnection(nodeInput: connection2)
        unNamedOutput.send(result: nil)
        XCTAssertNil(connection1.value)
        XCTAssertNil(connection2.value)
    }
}
