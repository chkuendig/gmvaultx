#import "NSTask+PTY.h"
#import <util.h>

@implementation NSTask (PTY)

- (NSFileHandle *)masterSideOfPTYOrError:(NSError *__autoreleasing *)error {
    int fdMaster, fdSlave;
    int rc = openpty(&fdMaster, &fdSlave, NULL, NULL, NULL);
    if (rc != 0) {
        if (error) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
        }
        return NULL;
    }
    fcntl(fdMaster, F_SETFD, FD_CLOEXEC);
    fcntl(fdSlave, F_SETFD, FD_CLOEXEC);
    NSFileHandle *masterHandle = [[NSFileHandle alloc] initWithFileDescriptor:fdMaster closeOnDealloc:YES];
    NSFileHandle *slaveHandle = [[NSFileHandle alloc] initWithFileDescriptor:fdSlave closeOnDealloc:YES];
    self.standardInput = slaveHandle;
    self.standardOutput = slaveHandle;
    self.standardError =slaveHandle;
    
    return masterHandle;
}

@end