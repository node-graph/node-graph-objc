#ifndef NodeCombinationType_h
#define NodeCombinationType_h

typedef NS_ENUM(NSUInteger, NodeCombinationType) {
    NodeCombinationTypeAny, // Fires as soon as any input is set.
    NodeCombinationTypeWhenAll, // All inputs have to be triggered between each run for the node to process.
    NodeCombinationTypeWhenAllAtLeastOnce, // Same as the one above but keeps the value so next run can start whenever any input is set.
    NodeCombinationTypeCustom, // Effectively the same as NodeCombinationTypeAny but signifies that the logic is defined by the node itself.
};

#endif /* NodeCombinationType_h */
