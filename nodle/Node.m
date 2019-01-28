#import "Node.h"

@interface AbstractNode ()

@property (nonatomic, assign, getter=isProcessing) BOOL processing;

@end

@implementation AbstractNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputTrigger = NodeInputTriggerAny;
        _inputs = [NSSet setWithObject:[[NodeInput alloc] initWithKey:nil
                                                           validation:nil
                                                             delegate:self]];
        _outputs = [NSSet setWithObject:[NodeOutput new]];
    }
    
    return self;
}

#pragma mark - Actions

- (void)process {
    if (self.processing) {
        return;
    }
    
    self.processing = YES;
    
    if ([self useDeferredProcessing]) {
        [self processDeferred];
    } else {
        [self processDirectly];
    }
}

- (void)cancel {
    // no-op
}

- (void)onProcess:(void (^)(id))completion {
    completion(nil);
}

- (void)sendResultToOutputs:(id)result {
    for (NodeOutput *output in self.outputs) {
        [output sendResult:result];
    }
}

#pragma mark - Processing

- (void)processDeferred {
    // Could be further optimized by storing the block for future use
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self processDirectly];
    });
}

- (void)processDirectly {
    [self onProcess:^(id  _Nonnull result) {
        self.processing = NO;
        // Done processing, call downstream nodes
        [self sendResultToOutputs:result];
    }];
}

#pragma mark - NodeInputDelegate

- (void)nodeInput:(NodeInput *)nodeInput didUpdateValue:(id)value {
    
}

#pragma mark - Helpers

/**
 Defer -onProcess: call to let inputs have a chance of being set during this run loop.
 */
- (BOOL)useDeferredProcessing {
    BOOL couldTriggerOnAnyInput = (self.inputTrigger == NodeInputTriggerAny ||
                                   self.inputTrigger == NodeInputTriggerAllAtLeastOnce ||
                                   self.inputTrigger == NodeInputTriggerCustom);
    return (self.inputs.count > 1 && couldTriggerOnAnyInput);
}


@end
