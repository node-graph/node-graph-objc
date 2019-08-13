#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface AbstractNode (Test)
@property (nonatomic, readonly) NodeInput *testInput;
@property (nonatomic, readonly) NodeOutput *testOutput;
@end
@implementation AbstractNode (Test)
- (NodeInput *)testInput {return [self.inputs anyObject];}
- (NodeOutput *)testOutput {return [self.outputs anyObject];}
@end

@interface NodeGraph (Tests)
@property (nonatomic, strong) NSMutableSet<id<Node>> *nodes;
@end

@interface NodeGraphTests : XCTestCase

@property (nonatomic, strong) AbstractNode *node1;
@property (nonatomic, strong) AbstractNode *node2;
@property (nonatomic, strong) AbstractNode *node3;
@property (nonatomic, strong) AbstractNode *node4;
@property (nonatomic, strong) AbstractNode *node5;
@property (nonatomic, strong) AbstractNode *node6;
@property (nonatomic, strong) NodeGraph *nodeGraph;

@end

@implementation NodeGraphTests

- (void)setUp {
    self.nodeGraph = [NodeGraph new];
    self.node1 = [AbstractNode new];
    self.node2 = [AbstractNode new];
    self.node3 = [AbstractNode new];
    self.node4 = [AbstractNode new];
    self.node5 = [AbstractNode new];
    self.node6 = [AbstractNode new];
}

- (void)tearDown {

}

#pragma mark - Chain

- (void)testAddingNonSelfContainedSetResultsInNoNodesAdded {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node1]]];
    
    XCTAssertTrue([self.nodeGraph.nodes count] == 0);
}

- (void)testAddingBranchingNodeSetHoldsAllNodes {
    [self.node1.testOutput addConnection:self.node2.testInput];
    
    // Branch
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node4.testInput];
    
    [self.node3.testOutput addConnection:self.node5.testInput];
    [self.node4.testOutput addConnection:self.node6.testInput];

    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5,
                                                     self.node6]]];
    
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node1]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node2]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node3]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node4]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node5]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node6]);
}

#pragma mark - Outputs

- (void)testAddingBranchingNodeChainCollectsAllDanglingOutputsInTreeAsOutputs {
    [self.node1.testOutput addConnection:self.node2.testInput];
    
    // Branch
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node4.testInput];
    
    [self.node3.testOutput addConnection:self.node5.testInput];
    [self.node4.testOutput addConnection:self.node6.testInput];
    
    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5,
                                                     self.node6]]];

    XCTAssertTrue([self.nodeGraph.outputs containsObject:self.node5.testOutput]);
    XCTAssertTrue([self.nodeGraph.outputs containsObject:self.node6.testOutput]);
    XCTAssertEqual([self.nodeGraph.outputs count], 2);
}

#pragma mark - Inputs

- (void)testAddingMultipleStartNodesCollectsAllStartInputsAsTreeInputs {
    // Start nodes
    [self.node1.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];

    [self.node3.testOutput addConnection:self.node4.testInput];
    [self.node4.testOutput addConnection:self.node5.testInput];
    
    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3,
                                                     self.node4,
                                                     self.node5]]];

    XCTAssertTrue([self.nodeGraph.inputs containsObject:self.node1.testInput]);
    XCTAssertTrue([self.nodeGraph.inputs containsObject:self.node2.testInput]);
    XCTAssertEqual([self.nodeGraph.inputs count], 2);
}

- (void)testCallingHoldTwiceWithDifferentChainsClearsTree {
    // Chain 1
    [self.node1.testOutput addConnection:self.node3.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    
    // Chain 2
    [self.node4.testOutput addConnection:self.node5.testInput];
    [self.node5.testOutput addConnection:self.node6.testInput];

    // Test
    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node1,
                                                     self.node2,
                                                     self.node3]]];
    [self.nodeGraph setNodeSet:[NSSet setWithArray:@[self.node4,
                                                     self.node5,
                                                     self.node6]]];
    
    // Verify
    XCTAssertTrue([self.nodeGraph.inputs containsObject:self.node4.testInput]);
    XCTAssertEqual([self.nodeGraph.inputs count], 1);
    
    XCTAssertTrue([self.nodeGraph.outputs containsObject:self.node6.testOutput]);
    XCTAssertEqual([self.nodeGraph.outputs count], 1);

    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node4]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node5]);
    XCTAssertTrue([self.nodeGraph.nodes containsObject:self.node6]);
    XCTAssertEqual([self.nodeGraph.nodes count], 3);
}

- (void)testSerializingNodeTreeWithThreeNodesHasDataWithThreeNodes {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.nodeGraph setNodeSet:[NSSet setWithObject:self.node1]];
    NSDictionary *serialized = [(id)self.nodeGraph serializedRepresentationAsDictionary];
    XCTAssertEqual([(NSArray *)serialized[@"data"][@"nodes"] count], 3);
}

- (void)testSerializingNodeTreeWithThreeNodesHasDataWithThreeConnections {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.nodeGraph setNodeSet:[NSSet setWithObject:self.node1]];
    NSDictionary *serialized = [(id)self.nodeGraph serializedRepresentationAsDictionary];
    XCTAssertEqual([(NSArray *)serialized[@"data"][@"connections"] count], 3);
}


// TODO: Test -process triggers all startNodes -process
// TODO: Test -cancel triggers all startNodes -cancel

@end
