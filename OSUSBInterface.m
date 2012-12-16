//
// opensn0w-ng
//
// OSUSBInterface.m
//

#include "OSUSBInterface.h"
#include "OSDFUDevice.h"

#define USB_LOG(format, ...) \
    NSLog(@"(%s:%d) %@", __PRETTY_FUNCTION__, __LINE__, \
                      [NSString stringWithFormat:format, ## __VA_ARGS__]);

@implementation OSUSBInterface

-(id)init {
    libusb_init(&libusbContext);
    USB_LOG(@"Initialized libusb");
    return [super init];
}

-(int)getUsbStringDescriptor:(uint8_t)descIndex:(uint8_t*)buffer:(int)size {
    return libusb_get_string_descriptor_ascii(libusbHandle,
                                              descIndex,
                                              buffer,
                                              size);
}

-(void)openDevice {
    int                             i, usb_device_count;
    struct libusb_device*           usb_device = NULL;
    struct libusb_device**          usb_device_list = NULL;
    struct libusb_device_handle*    usb_handle = NULL;
    struct libusb_device_descriptor usb_descriptor;

    USB_LOG(@"Opening device");

    usb_device_count = libusb_get_device_list(libusbContext,
                                              &usb_device_list);
    for(i = 0; i < usb_device_count; i++) {
        usb_device = usb_device_list[i];
        libusb_get_device_descriptor(usb_device, &usb_descriptor);
        if (usb_descriptor.idVendor == kAppleVendorID) {
            if (usb_descriptor.idProduct == kDfuMode ||
                usb_descriptor.idProduct == kRecoveryMode) {
                
                USB_LOG(@"opening device %04x:%04x...", 
                        usb_descriptor.idVendor,
                        usb_descriptor.idProduct);
                
                libusb_open(usb_device, &usb_handle);
                
                if(!usb_handle) {
                    USB_LOG(@"can't connect to device...");
                    libusb_close(usb_handle);
                    libusb_free_device_list(usb_device_list, 1);
                    libusb_exit(libusbContext);
                }

                usbInterface = 0;
                usbAlternateInterface = 0;
                usbMode = usb_descriptor.idProduct;
                libusbHandle = usb_handle;

                uint8_t serialNumber[256];;
                OSDFUDevice* device = [OSDFUDevice sharedDevice];

                [self getUsbStringDescriptor:usb_descriptor.iSerialNumber
                                            :serialNumber
                                            :255];
                [device setDefaultsOnDfuString:[NSString stringWithUTF8String:(char*)serialNumber]];

                [self setConfiguration:1];
                if(usbMode == kRecoveryMode) {
                    [self setInterface:0:0];
                    [self setInterface:1:1];
                } else {
                    [self setInterface:0:0];
                }
            }
        }
    }
}

-(void)closeDevice {
    if(libusbHandle) {
        if(usbMode != kDfuMode)
            libusb_release_interface(libusbHandle, usbInterface);
        libusb_close(libusbHandle);
        libusbHandle = NULL;
    }
}

-(void)resetDevice {
    libusb_reset_device(libusbHandle);
}

-(void)setConfiguration:(int)withConfiguration {
    int current = 0;
    libusb_get_configuration(libusbHandle, &current);
    if (current != withConfiguration) {
        if (libusb_set_configuration(libusbHandle, withConfiguration) < 0) {
            USB_LOG(@"Failed to set configuration.");
            return;
        }
    }
    usbConfiguration = withConfiguration;
}

-(void)setInterface:(int)interface:(int)alternateInterface {
    USB_LOG(@"Setting interface to %x:%x", interface, alternateInterface);

    if (libusb_claim_interface(libusbHandle, interface) < 0) {
        USB_LOG(@"Failed to claim interface.");
        return;
    }

    if (libusb_set_interface_alt_setting(libusbHandle, interface, 
                                         alternateInterface) < 0) {
        USB_LOG(@"Failed to set interfaces.");
        return;
    }

    usbInterface = interface;
    usbAlternateInterface = alternateInterface;
}

-(void)finishTransfer {
    int i;
    USB_LOG(@"Signaling end of transfer.");
    [self controlTransfer:0x21:1:0:0:0:0:1000];
    for(i = 0; i < 3; i++) {
        [self getStatus];
    }
}

-(void)resetCounters {
    USB_LOG(@"Resetting counters.");
    if(usbMode == kDfuMode) {
        [self controlTransfer:0x21:4:0:0:0:0:1000];
    }
}

-(void)sendCommand:(NSString*)commandName {
    uint32_t length;
    uint8_t *buffer;

    USB_LOG(@"Sending command \"%@\".", commandName);

    buffer = (uint8_t*)[commandName UTF8String];
    length = strlen((char*)buffer);
    if(length >= 0x100)
        length = 0xFF;

    if(length)
        [self controlTransfer:0x40:0:0:0:buffer:length+1:1000];
}

-(int)getStatus {
    uint8_t buffer[6];
    memset(buffer, 0, 6);
    USB_LOG(@"Getting status.");
    [self controlTransfer:0xA1:3:0:0:buffer:6:1000];
    return buffer[4];
}

-(int)controlTransfer:(uint8_t)bmRequestType:(uint8_t)bRequest:(uint16_t)wValue:(uint16_t)wIndex:(uint8_t*)data:(uint8_t)wLength:(uint32_t)timeout {
    return libusb_control_transfer(libusbHandle,
                                   bmRequestType,
                                   bRequest,
                                   wValue,
                                   wIndex,
                                   data,
                                   wLength,
                                   timeout);
}


@end
