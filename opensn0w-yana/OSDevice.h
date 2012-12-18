//
// OSDevice.h
//
// opensn0w-ng
//

#ifndef _OSDevice_h_
#define _OSDevice_h_

#include <Foundation/Foundation.h>
#include "OSObject.h"
#include "OSUSBInterface.h"

typedef enum {
    kARMv4 = 0,
    kARMv5,
    kARMv6,
    kARMv7,
    kARMv7f,
    kARMv7s
} kDeviceArchitecture;

typedef struct _OSDeviceList {
    NSString*               deviceName;
    NSString*               deviceCanonicalName;
    uint32_t                deviceChipIdentifier;
    kDeviceArchitecture     deviceArchitecture;
    uint32_t                deviceBoardIdentifier;
} OSDeviceList, *OSDeviceListRef;

extern OSDeviceList deviceList[];

@interface OSDevice : OSObject {
@private
    /*! Device Identifiers */
    NSString*           deviceName;
    NSString*           deviceSerialNumber;
    NSString*           deviceCanonicalName;
    uint32_t            deviceChipIdentifier;
    uint64_t            deviceEcid;
    /*! Device Nonce, specific to iBSS-1219+ and SecureROM-1145.3+ */
    NSData*             deviceNonce;
    /*! String that has device DFU string */
    NSString*           deviceDfuString;
    OSUSBInterface      *usbInterface;
}

#pragma mark - Singleton methods
+(OSDevice*)sharedDevice;

#pragma mark - Base methods
-(void)setDefaultsPerDeviceName:(NSString*)withProfile;
-(void)setDefaultsOnDfuString:(NSString*)withDfuString;

#pragma mark - Getter methods
-(NSString*)deviceName;
-(NSString*)deviceSerialNumber;
-(uint32_t)deviceChipIdentifier;
-(uint64_t)deviceEcid;
-(NSData*)deviceNonce;

-(OSUSBInterface*)usbInterface;

#pragma mark - Setter methods
-(void)setDeviceName:(NSString*)withName;
-(void)setDeviceSerialNumber:(NSString*)withSerialNumber;
-(void)setDeviceChipIdentifier:(uint32_t)withChipIdentifier;
-(void)setDeviceEcid:(uint64_t)withEcid;
-(void)setDeviceNonce:(NSData*)withNonce;

@end

#endif
