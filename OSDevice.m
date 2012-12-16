//
// OSDevice.m
//
// opensn0w-ng
//

#include "OSDevice.h"

static OSDeviceListRef currentProfile;
static void* sharedDevice = nil;
static BOOL usbInitialized = NO;

OSDeviceList deviceList[] = {
    /*! Other */
    {@"k66ap", @"Apple TV 2G", 0x8930, kARMv7, 16},
    {@"j33ap", @"Apple TV 3G", 0x8942, kARMv7f, 8},
    /*! iPhones */
    {@"m68ap", @"iPhone 2G", 0x8900, kARMv6, 0},
    {@"n82ap", @"iPhone 3G", 0x8900, kARMv6, 4},
    {@"n88ap", @"iPhone 3GS", 0x8920, kARMv7, 0},
    {@"n90ap", @"iPhone 4", 0x8930, kARMv7, 0},
    {@"n92ap", @"iPhone 4 CDMA", 0x8930, kARMv7, 6},
    {@"n94ap", @"iPhone 4S", 0x8940, kARMv7f, 8},
    {@"n41ap", @"iPhone 5", 0x8950, kARMv7s, 0},
    {@"n42ap", @"iPhone 5 CDMA", 0x8950, kARMv7s, 2},
    /*! iPod touches */
    {@"n45ap", @"iPod touch 1G", 0x8900, kARMv6, 2},
    {@"n72ap", @"iPod touch 2G", 0x8720, kARMv6, 0},
    {@"n18ap", @"iPod touch 3G", 0x8922, kARMv7, 2},
    {@"n81ap", @"iPod touch 4G", 0x8930, kARMv7, 8},
    {@"n78ap", @"iPod touch 5G", 0x8942, kARMv7f, 0},
    /*! iPads */
    {@"k48ap", @"iPad 1G", 0x8930, kARMv7, 2},
    {@"k93ap", @"iPad 2 Wi-Fi", 0x8940, kARMv7f, 4},
    {@"k94ap", @"iPad 2 Cellular (k94)", 0x8940, kARMv7f, 6},
    {@"k95ap", @"iPad 2 Cellular (k95)", 0x8940, kARMv7f, 2},
    {@"k93aap", @"iPad 2 Wi-Fi Revision A", 0x8942, kARMv7f, 6},
    {@"j1ap", @"iPad 3 Wi-Fi", 0x8945, kARMv7f, 0},
    {@"j2ap", @"iPad 3 Cellular (j2)", 0x8945, kARMv7f, 2},
    {@"j2aap", @"iPad 3 Cellular (j2a)", 0x8945, kARMv7f, 4},
    {@"p101ap", @"iPad 4 Wi-Fi", 0x8955, kARMv7s, 0},
    {@"p102ap", @"iPad 4 Cellular (p102)", 0x8955, kARMv7s, 2},
    {@"p103ap", @"iPad 4 Cellular (p103)", 0x8955, kARMv7s, 4},
    {@"p105ap", @"iPad mini Wi-Fi", 0x8942, kARMv7f, 10},
    {@"p106ap", @"iPad mini Cellular (p105)", 0x8942, kARMv7f, 12},
    {@"p107ap", @"iPad mini Cellular (p106)", 0x8942, kARMv7f, 14},
    {NULL, NULL, 0, 0, 0}
};

@implementation OSDevice

#pragma mark - Singleton method

+(OSDevice*)sharedDevice {
    while(!sharedDevice) {
        OSDevice* device = [[[self class] alloc] init];
        @synchronized([OSDevice class]) {
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

#pragma mark - Getter methods

-(NSString*)deviceName {
    return [[deviceName copy] autorelease];
}

-(NSString*)deviceSerialNumber {
    return [[deviceSerialNumber copy] autorelease];
}

-(uint32_t)deviceChipIdentifier {
    return deviceChipIdentifier;
}

-(uint64_t)deviceEcid {
    return deviceEcid;
}

-(NSData*)deviceNonce {
    return [[deviceNonce copy] autorelease];
}

-(OSUSBInterface*)usbInterface {
    @synchronized([OSDevice class]) {
        if(usbInitialized == NO) {
            return [[OSUSBInterface alloc] init];
        } else {
            return nil;
        }
        usbInitialized = YES;
    }
}

#pragma mark - Setter methods

-(void)setDeviceName:(NSString*)withName {
    [withName retain];
    [deviceName release];
    deviceName = withName;
}

-(void)setDeviceSerialNumber:(NSString*)withSerialNumber {
    [withSerialNumber retain];
    [deviceSerialNumber release];
    deviceSerialNumber = withSerialNumber;
}

-(void)setDeviceChipIdentifier:(uint32_t)withChipIdentifier {
    deviceChipIdentifier = withChipIdentifier;
}

-(void)setDeviceEcid:(uint64_t)withDeviceEcid {
    deviceEcid = withDeviceEcid;
}

-(void)setDeviceNonce:(NSData*)withNonce {
    [withNonce retain];
    [deviceNonce release];
    deviceNonce = withNonce;
}

#pragma mark - Base methods

-(void)setDefaultsOnDfuString:(NSString*)withDfuString {
    const char          *utf8String;
    int                 boardIdentifier = 0, chipIdentifier = 8900;
    uint64_t            _deviceEcid = 0;
    char                *ecidString, *bdidString, *cpidString, *srnmString;
    char                *serialNumber = 0, *p;
    int                 i = 0;
    OSDeviceListRef     currentDevice = &deviceList[0];

    NSLog(@"Setting device profile based on %@", withDfuString);

    utf8String = [withDfuString UTF8String];

    ecidString = strstr(utf8String, "ECID:");
    if(!ecidString) {
        NSLog(@"Failed to get ECID.");
    } else {
         sscanf(ecidString, "ECID:%qX", &_deviceEcid);
    }

    bdidString = strstr(utf8String, "BDID:");
    if(!bdidString) {
        NSLog(@"Failed to get BDID.");
    } else {
        sscanf(bdidString, "BDID:%x", &boardIdentifier);
    }

    cpidString = strstr(utf8String, "CPID:");
    if(!cpidString) {
        NSLog(@"Failed to get CPID.");
    } else {
        sscanf(cpidString, "CPID:%x", &chipIdentifier);
    }

    srnmString = strstr(utf8String, "SRNM:[");
    if(!srnmString) {
        NSLog(@"Failed to get SRNM, not bad though.");
    } else {
        sscanf(srnmString, "SRNM:[%s]", serialNumber);
    }

    if(serialNumber) {
        p = strrchr(serialNumber, ']');
        if(p) {
            *p = '\0';
        }
    }

    while(currentDevice != NULL && currentDevice->deviceName != NULL) {
        if(currentDevice->deviceName != NULL) {
            if(chipIdentifier == currentDevice->deviceChipIdentifier &&
               boardIdentifier == currentDevice->deviceBoardIdentifier) {
                NSLog(@"Profile: %p {%@, %@, %d, %d}",
                      currentDevice,
                      currentDevice->deviceName,
                      currentDevice->deviceCanonicalName,
                      currentDevice->deviceChipIdentifier,
                      currentDevice->deviceArchitecture);
                [self setDeviceName:currentDevice->deviceName];
                [self setDeviceChipIdentifier:
                                    currentDevice->deviceChipIdentifier];
                if(serialNumber) {
                    NSString *serialString;
                    serialString = [NSString stringWithUTF8String:
                                                   serialNumber];
                    [self setDeviceSerialNumber:serialString];
                }
                [self setDeviceEcid:_deviceEcid];
                currentProfile = currentDevice;
                break;
            }
        }
        i++;
        currentDevice = &deviceList[i];
    }

}

-(void)setDefaultsPerDeviceName:(NSString*)withProfile {
    OSDeviceListRef     currentDevice = &deviceList[0];
    int                 i = 0;

    NSLog(@"Setting device profile based on %@", withProfile);

    while(currentDevice != NULL && currentDevice->deviceName != NULL) {
        if(currentDevice->deviceName != NULL) {
            NSString *_deviceName = currentDevice->deviceName;
            if([withProfile isEqualToString:_deviceName]
                                         == YES) {
                NSLog(@"Profile: %p {%@, %@, %d, %d}",
                      currentDevice,
                      currentDevice->deviceName,
                      currentDevice->deviceCanonicalName,
                      currentDevice->deviceChipIdentifier,
                      currentDevice->deviceArchitecture);
                [self setDeviceName:currentDevice->deviceName];
                [self setDeviceChipIdentifier:
                                    currentDevice->deviceChipIdentifier];
                currentProfile = currentDevice;
                break;
            }
        }
        i++;
        currentDevice = &deviceList[i];
    }
}

@end
