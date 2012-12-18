//
// opensn0w-ng
//
// OSUSBInterface.h
//

#ifndef _OSUSBInterface_h_
#define _OSUSBInterface_h_

#include <Foundation/Foundation.h>
#include <libusb-1.0/libusb.h>
#include "OSObject.h"

typedef enum {
    kDfuMode = 0x1227,
    kRecoveryMode = 0x1281,
    kNormalMode = 0xBEEF
} kMode;

#define kAppleVendorID      0x05AC

@interface OSUSBInterface : OSObject {
    uint32_t                debugLevel;
    libusb_context*         libusbContext;
    libusb_device_handle*   libusbHandle;
    uint32_t                usbInterface;
    uint32_t                usbAlternateInterface;
    uint32_t                usbConfiguration;
    kMode                   usbMode;
    char*                   usbSerialNumber;
}

-(void)openDevice;
-(void)closeDevice;
-(void)resetDevice;
-(void)setConfiguration:(int)withConfiguration;
-(void)setInterface:(int)interface:(int)alternateInterface;
-(void)sendCommand:(NSString*)commandName;
-(void)resetCounters;
-(void)finishTransfer;
-(int)controlTransfer:(uint8_t)bmRequestType:(uint8_t)bRequest:(uint16_t)wValue:(uint16_t)wIndex:(uint8_t*)data:(uint8_t)wLength:(uint32_t)timeout;
-(int)getUsbStringDescriptor:(uint8_t)descIndex:(uint8_t*)buffer:(int)size;
-(int)getStatus;
@end

#endif
