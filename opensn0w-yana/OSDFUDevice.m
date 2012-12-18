//
// opensn0w-ng
//
// OSDFUDevice.m 
//

#include "OSDFUDevice.h"

static void *sharedDevice = nil;

@implementation OSDFUDevice

-(id)init {
    OSDevice *device = [OSDevice sharedDevice];
    /*! HACK */
    [self setDeviceName:[device deviceName]];
    [self setDeviceSerialNumber:[device deviceSerialNumber]];
    [self setDeviceChipIdentifier:[device deviceChipIdentifier]];
    [self setDeviceEcid:[device deviceEcid]];
    [super init];
    return self;
}

+(OSDFUDevice*)sharedDevice {
    while(!sharedDevice) {
        OSDFUDevice* device = [[[self class] alloc] init];
        @synchronized([OSDFUDevice class]) {
            if(device) {
                sharedDevice = (void*)device;
            }
            if(!sharedDevice) {
                [device release];
            }
        }
    }
    return sharedDevice;
}

-(BOOL)isDeviceInDfu {
    return YES;
}

@end
