#import "NodeOutput.h"
#import "NodeInput.h"

@implementation NodeOutput

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
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

- (void)addConnection:(NodeInput *)connection {
    if (!connection) {
        return;
    }
    [self.connections addObject:connection];
}

- (void)removeConnection:(NodeInput *)connection {
    [self.connections removeObject:connection];
}

- (void)sendResult:(nullable id)result {
    for (NodeInput *connection in self.connections) {
        [connection setValue:result];
    }
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> key:%@ numberOfConnections:%tu", NSStringFromClass(self.class), self, self.key ?: @"", self.connections.count];
}

@end
