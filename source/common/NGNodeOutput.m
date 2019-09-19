#import "NGNodeOutput.h"
#import "NGNodeInput.h"

@implementation NGNodeOutput

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // Caution, NSHashTable .count reports wrong value if item was dropped due to weak reference becoming nil.
        _connections = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key {
    self = [self init];
    if (self) {
        _key = key;
    }
    return self;
}

+ (instancetype)output {
    return [[self alloc] init];
}

+ (instancetype)outputWithKey:(NSString *)key {
    return [[self alloc] initWithKey:key];
}

#pragma mark - Actions

- (void)addConnection:(NGNodeInput *)connection {
    if (!connection) {
        return;
    }
    [self.connections addObject:connection];
}

- (void)removeConnection:(NGNodeInput *)connection {
    [self.connections removeObject:connection];
}

- (void)sendResult:(nullable id)result {
    for (NGNodeInput *connection in self.connections) {
        [connection setValue:result];
    }
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> key:%@ numberOfConnections:%tu", NSStringFromClass(self.class), self, self.key ?: @"", self.connections.allObjects.count];
}

@end
