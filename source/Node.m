#import "Node.h"

@interface AbstractNode ()

@property (nonatomic, assign, getter=isProcessing) BOOL processing;
@property (nonatomic, assign) NSTimeInterval processingTime;
@property (nonatomic, assign) NSTimeInterval processingStartTime;
@property (nonatomic, assign, getter=isCanceling) BOOL canceling;

@end

@implementation AbstractNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        _processingTime = 0;
        _inputTrigger = NodeInputTriggerAny;
        _inputs = [NSSet setWithObject:[[NodeInput alloc] initWithKey:nil
                                                           validation:nil
                                                                 node:self]];
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
    self.processingStartTime = [[NSDate date] timeIntervalSince1970];
    
    if ([self useDeferredProcessing]) {
        [self processDeferred];
    } else {
        [self processDirectly];
    }
}

- (void)cancel {
    if (self.canceling) {
        return;
    }
    self.canceling = YES;
    for (NodeOutput *output in self.outputs) {
        for (NodeInput *connection in output.connections) {
            [connection.node cancel];
        }
    }
    self.canceling = NO;
}

- (void)doProcess:(void (^)(void))completion {
    // Default implementation just passes value to output.
    // This method should be overridden in subclass
    [[self.outputs anyObject] sendResult:[[self.inputs anyObject] value]];
    completion();
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
    [self doProcess:^(){
        self.processingTime = [[NSDate date] timeIntervalSince1970] - self.processingStartTime;
        self.processing = NO;
    }];
}

#pragma mark - NodeInputDelegate

- (void)nodeInput:(NodeInput *)nodeInput didUpdateValue:(id)value {
    if ([self canRun]) {
        [self process];
    }
}

- (BOOL)canRun {
    switch (self.inputTrigger) {
        case NodeInputTriggerAny: {
            for (NodeInput *input in self.inputs) {
                if (input.value) {
                    return YES;
                }
            }
            break;
        }
        case NodeInputTriggerAll: {
            for (NodeInput *input in self.inputs) {
                if (!input.value) {
                    return NO;
                }
            }
            return YES;
        }
        case NodeInputTriggerAllAtLeastOnce: {
            // TODO
            break;
        }
        case NodeInputTriggerNoAutomaticProcessing: {
            return NO;
        }
        case NodeInputTriggerCustom: {
            return YES;
        }
    }
    return NO;
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
