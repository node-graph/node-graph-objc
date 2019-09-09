#import <XCTest/XCTest.h>
#import <NodeGraph/NodeGraph.h>

@interface NGAbstractNode (Test)
@property (nonatomic, readonly) NodeInput *testInput;
@property (nonatomic, readonly) NodeOutput *testOutput;
@end
@implementation NGAbstractNode (Test)
- (NodeInput *)testInput {return [self.inputs anyObject];}
- (NodeOutput *)testOutput {return [self.outputs anyObject];}
@end

@interface GraphNode (Tests)
@property (nonatomic, strong) NSMutableSet<id<NGNode>> *nodes;
@end

@interface GraphNodeTests : XCTestCase

@property (nonatomic, strong) NGAbstractNode *node1;
@property (nonatomic, strong) NGAbstractNode *node2;
@property (nonatomic, strong) NGAbstractNode *node3;
@property (nonatomic, strong) NGAbstractNode *node4;
@property (nonatomic, strong) NGAbstractNode *node5;
@property (nonatomic, strong) NGAbstractNode *node6;
@property (nonatomic, strong) GraphNode *graphNode;

@end

@implementation GraphNodeTests

- (void)setUp {
    self.graphNode = [GraphNode new];
    self.node1 = [NGAbstractNode new];
    self.node2 = [NGAbstractNode new];
    self.node3 = [NGAbstractNode new];
    self.node4 = [NGAbstractNode new];
    self.node5 = [NGAbstractNode new];
    self.node6 = [NGAbstractNode new];
}

- (void)tearDown {

}

#pragma mark - Chain

- (void)testAddingNonSelfContainedSetResultsInNoNodesAdded {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1]]];
    
    XCTAssertTrue([self.graphNode.nodes count] == 0);
}

- (void)testAddingBranchingNodeSetHoldsAllNodes {
    [self.node1.testOutput addConnection:self.node2.testInput];
    
    // Branch
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node4.testInput];
    
    [self.node3.testOutput addConnection:self.node5.testInput];
    [self.node4.testOutput addConnection:self.node6.testInput];

    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5,
                                                     self.node6]]];
    
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node1]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node2]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node3]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node4]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node5]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node6]);
}

#pragma mark - Outputs

- (void)testAddingBranchingNodeChainCollectsAllDanglingOutputsInTreeAsOutputs {
    [self.node1.testOutput addConnection:self.node2.testInput];
    
    // Branch
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node4.testInput];
    
    [self.node3.testOutput addConnection:self.node5.testInput];
    [self.node4.testOutput addConnection:self.node6.testInput];
    
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5,
                                                     self.node6]]];

    XCTAssertTrue([self.graphNode.outputs containsObject:self.node5.testOutput]);
    XCTAssertTrue([self.graphNode.outputs containsObject:self.node6.testOutput]);
    XCTAssertEqual([self.graphNode.outputs count], 2);
}

#pragma mark - Inputs

- (void)testAddingMultipleStartNodesCollectsAllStartInputsAsTreeInputs {
    // Start nodes
    [self.node1.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];

    [self.node3.testOutput addConnection:self.node4.testInput];
    [self.node4.testOutput addConnection:self.node5.testInput];
    
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5]]];

    XCTAssertTrue([self.graphNode.inputs containsObject:self.node1.testInput]);
    XCTAssertTrue([self.graphNode.inputs containsObject:self.node2.testInput]);
    XCTAssertEqual([self.graphNode.inputs count], 2);
}

- (void)testCallingHoldTwiceWithDifferentChainsClearsTree {
    // Chain 1
    [self.node1.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    
    // Chain 2
    [self.node4.testOutput addConnection:self.node5.testInput];
    [self.node5.testOutput addConnection:self.node6.testInput];

    // Test
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3]]];
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node4,
                                                     self.node5,
                                                     self.node6]]];
    
    // Verify
    XCTAssertTrue([self.graphNode.inputs containsObject:self.node4.testInput]);
    XCTAssertEqual([self.graphNode.inputs count], 1);
    
    XCTAssertTrue([self.graphNode.outputs containsObject:self.node6.testOutput]);
    XCTAssertEqual([self.graphNode.outputs count], 1);

    XCTAssertTrue([self.graphNode.nodes containsObject:self.node4]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node5]);
    XCTAssertTrue([self.graphNode.nodes containsObject:self.node6]);
    XCTAssertEqual([self.graphNode.nodes count], 3);
}

- (void)testSerializingNodeTreeWithThreeNodesHasDataWithThreeNodes {
    // Simple connetions
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    
    // Add to graph
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3]]];
    
    // Serialize
    NSDictionary *serialized = [(id)self.graphNode serializedRepresentationAsDictionary];
    XCTAssertEqual([(NSArray *)serialized[@"data"][@"nodes"] count], 3);
}

- (void)testSerializingNodeTreeWithThreeNodesHasDataWithThreeConnections {
    // Simple connetions
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    
    // Add to graph
    [self.graphNode setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3]]];
    
    // Serialize
    NSDictionary *serialized = [(id)self.graphNode serializedRepresentationAsDictionary];
    XCTAssertEqual([(NSArray *)serialized[@"data"][@"connections"] count], 3);
}


// TODO: Test -process triggers all startNodes -process
// TODO: Test -cancel triggers all startNodes -cancel

@end
