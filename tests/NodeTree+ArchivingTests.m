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

@interface NodeTree (Tests)
@property (nonatomic, strong) NSMutableSet<id<Node>> *nodes;
@end

@interface NodeTree_ArchivingTests : XCTestCase

@property (nonatomic, strong) AbstractNode *node1;
@property (nonatomic, strong) AbstractNode *node2;
@property (nonatomic, strong) AbstractNode *node3;
@property (nonatomic, strong) AbstractNode *node4;
@property (nonatomic, strong) AbstractNode *node5;
@property (nonatomic, strong) AbstractNode *node6;
@property (nonatomic, strong) NodeTree *nodeTree;

@end

@implementation NodeTree_ArchivingTests

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

- (void)testArchiveHasThreeNodesForThreeNodeTree {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithObject:self.node1]];
    NSDictionary *treeArchive = [(id)self.nodeTree asArchivedDictionary];
    XCTAssertEqual([(NSArray *)treeArchive[@"nodes"] count], 3);
}

- (void)testArchiveHasThreeConnectionsNodesForThreeNodeTree {
    [self.node1.testOutput addConnection:self.node2.testInput];
    [self.node2.testOutput addConnection:self.node3.testInput];
    [self.nodeTree holdNodeChainWithStartNodes:[NSSet setWithObject:self.node1]];
    NSDictionary *treeArchive = [(id)self.nodeTree asArchivedDictionary];
    XCTAssertEqual([(NSArray *)treeArchive[@"connections"] count], 3);
}


@end
