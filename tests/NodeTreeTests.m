#import <XCTest/XCTest.h>
#import <nodle/nodle.h>

@interface NodeTree (Tests)
@property (nonatomic, strong) NSMutableSet<id<Node>> *nodes;
@end

@interface NodeTreeTests : XCTestCase

@property (nonatomic, strong) AbstractNode *node1;
@property (nonatomic, strong) AbstractNode *node2;
@property (nonatomic, strong) AbstractNode *node3;
@property (nonatomic, strong) AbstractNode *node4;
@property (nonatomic, strong) AbstractNode *node5;
@property (nonatomic, strong) AbstractNode *node6;
@property (nonatomic, strong) NodeTree *nodeTree;

@end

@implementation NodeTreeTests

- (void)setUp {
    self.nodeTree = [NodeTree new];
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

- (void)testAddingSingleBranchNodeChainHoldsAllNodes {
    [[self.node1.outputs anyObject] addConnection:[self.node2.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node1]]];
    
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node1]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node2]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node3]);
}

- (void)testAddingSingleBranchNodeChainHoldsOnlyDownstreamNodesFromStartNode {
    [[self.node1.outputs anyObject] addConnection:[self.node2.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node2]]];
    
    XCTAssertFalse([self.nodeTree.nodes containsObject:self.node1]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node2]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node3]);
}

- (void)testAddingBranchingNodeChainHoldsAllNodes {
    [[self.node1.outputs anyObject] addConnection:[self.node2.inputs anyObject]];
    
    // Branch
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node4.inputs anyObject]];
    
    [[self.node3.outputs anyObject] addConnection:[self.node5.inputs anyObject]];
    [[self.node4.outputs anyObject] addConnection:[self.node6.inputs anyObject]];

    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node1]]];
    
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node1]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node2]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node3]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node4]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node5]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node6]);
}

#pragma mark - Outputs

- (void)testAddingBranchingNodeChainCollectsAllDanglingOutputsInAsTreeOutputs {
    [[self.node1.outputs anyObject] addConnection:[self.node2.inputs anyObject]];
    
    // Branch
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node4.inputs anyObject]];
    
    [[self.node3.outputs anyObject] addConnection:[self.node5.inputs anyObject]];
    [[self.node4.outputs anyObject] addConnection:[self.node6.inputs anyObject]];
    
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node1]]];
    
    XCTAssertTrue([self.nodeTree.outputs containsObject:[self.node5.outputs anyObject]]);
    XCTAssertTrue([self.nodeTree.outputs containsObject:[self.node6.outputs anyObject]]);
    XCTAssertEqual([self.nodeTree.outputs count], 2);
}

#pragma mark - Inputs

- (void)testAddingMultipleStartNodesCollectsAllStartInputsAsTreeInputs {
    // Start nodes
    [[self.node1.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];

    [[self.node3.outputs anyObject] addConnection:[self.node4.inputs anyObject]];
    [[self.node4.outputs anyObject] addConnection:[self.node5.inputs anyObject]];
    
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node1, self.node2]]];
    
    XCTAssertTrue([self.nodeTree.inputs containsObject:[self.node1.inputs anyObject]]);
    XCTAssertTrue([self.nodeTree.inputs containsObject:[self.node2.inputs anyObject]]);
    XCTAssertEqual([self.nodeTree.inputs count], 2);
}

- (void)testCallingHoldTwiceWithDifferentChainsClearsTree {
    // Chain 1
    [[self.node1.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    [[self.node2.outputs anyObject] addConnection:[self.node3.inputs anyObject]];
    
    // Chain 2
    [[self.node4.outputs anyObject] addConnection:[self.node5.inputs anyObject]];
    [[self.node5.outputs anyObject] addConnection:[self.node6.inputs anyObject]];

    // Test
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node1]]];
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithArray:@[self.node4]]];
    
    // Verify
    XCTAssertTrue([self.nodeTree.inputs containsObject:[self.node4.inputs anyObject]]);
    XCTAssertEqual([self.nodeTree.inputs count], 1);
    
    XCTAssertTrue([self.nodeTree.outputs containsObject:[self.node6.outputs anyObject]]);
    XCTAssertEqual([self.nodeTree.outputs count], 1);

    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node4]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node5]);
    XCTAssertTrue([self.nodeTree.nodes containsObject:self.node6]);
    XCTAssertEqual([self.nodeTree.nodes count], 3);
}

// TODO: Test -process triggers all startNodes -process
// TODO: Test -cancel triggers all startNodes -cancel

@end
