//
// opensn0w-ng
//
// OSDFUDevice.h
//

#ifndef _OSDFUDevice_h_
#define _OSDFUDevice_h_

#include <Foundation/Foundation.h>
#include "OSObject.h"
#include "OSDevice.h"

@interface OSDFUDevice : OSDevice {
    uint32_t    deviceCprv;
    uint32_t    deviceScep;
    uint32_t    deviceIbfl;
    NSString*   deviceSrtg;
}

#pragma mark - Singleton methods
+(OSDFUDevice*)sharedDevice;

#pragma mark - Other methods
-(BOOL)isDeviceInDfu;
@end

#endif
