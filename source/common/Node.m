#import "NGNode.h"
#import "NGNodeSerializationUtils.h"

@interface NGAbstractNode ()

@property (nonatomic, assign, getter=isProcessing) BOOL processing;
@property (nonatomic, assign) NSTimeInterval processingTime;
@property (nonatomic, assign) NSTimeInterval processingStartTime;
@property (nonatomic, assign, getter=isCanceling) BOOL canceling;

@end

@implementation NGAbstractNode

@synthesize inputTrigger = _inputTrigger;
@synthesize inputs = _inputs;
@synthesize outputs = _outputs;

- (instancetype)init {
    self = [super init];
    if (self) {
        _processingTime = 0;
        _inputTrigger = NGNodeInputTriggerAny;
        _inputs = [NSSet setWithObject:[[NGNodeInput alloc] initWithKey:nil
                                                             validation:nil
                                                                   node:self]];
        _outputs = [NSSet setWithObject:[NGNodeOutput new]];
    }
    
    return self;
}

- (NSString *)nodeName {
    return NSStringFromClass(self.class);
}

#pragma mark - Actions

- (void)process {
    if (self.processing) {
        return;
    }
    
    self.processing = YES;
    self.processingStartTime = [[NSDate date] timeIntervalSince1970];
    
    void(^processCompletion)(void) = ^(){
        self.processingTime = [[NSDate date] timeIntervalSince1970] - self.processingStartTime;
        self.processing = NO;
    };
    if ([self useDeferredProcessing]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self doProcess:processCompletion];
        });
    } else {
        [self doProcess:processCompletion];
    }
}

- (void)cancel {
    if (self.canceling) {
        return;
    }
    self.canceling = YES;
    for (NGNodeOutput *output in self.outputs) {
        for (NGNodeInput *connection in output.connections) {
            [connection.node cancel];
        }
    }
    self.canceling = NO;
}

- (void)doProcess:(void (^)(void))completion {
    // Default implementation just passes value to output.
    // This method should be overridden in your subclass
    [[self.outputs anyObject] sendResult:[[self.inputs anyObject] value]];
    // Completion must always be called at some point, however it can be async
    completion();
}

#pragma mark - NGNodeInputDelegate

- (void)nodeInput:(NGNodeInput *)nodeInput didUpdateValue:(id)value {
    if ([self shouldProcess]) {
        [self process];
    }
}

- (BOOL)shouldProcess {
    switch (self.inputTrigger) {
        case NGNodeInputTriggerAny: {
            for (NGNodeInput *input in self.inputs) {
                if (input.value) {
                    return YES;
                }
            }
            break;
        }
        case NGNodeInputTriggerAll: {
            for (NGNodeInput *input in self.inputs) {
                if (!input.value) {
                    return NO;
                }
            }
            return YES;
        }
        case NGNodeInputTriggerAllAtLeastOnce: {
            // TODO
            break;
        }
        case NGNodeInputTriggerNoAutomaticProcessing: {
            return NO;
        }
        case NGNodeInputTriggerCustom: {
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
    BOOL couldTriggerOnAnyInput = (self.inputTrigger == NGNodeInputTriggerAny ||
                                   self.inputTrigger == NGNodeInputTriggerAllAtLeastOnce ||
                                   self.inputTrigger == NGNodeInputTriggerCustom);
    return (self.inputs.count > 1 && couldTriggerOnAnyInput);
}

#pragma mark - SerializableNode

- (NSString *)serializedType {
    return NSStringFromClass([self class]);
}

- (NSDictionary *)serializedRepresentationAsDictionary {
    return [NGNodeSerializationUtils serializedRepresentationAsDictionaryFromNode:self];
}

- (NSDictionary<NSString *, NSArray *> *)serializedOutputConnectionsWithNodeMapping:(NSDictionary<NSString *,id<NGSerializableNode>> *)nodeMapping {
    return [NGNodeSerializationUtils serializedOutputConnectionsFromNode:self
                                                         withNodeMapping:nodeMapping];
}

@end
