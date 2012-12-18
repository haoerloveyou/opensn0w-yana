//
// opensn0w-ng
//
// Device Testing Harness
//

#include <Foundation/Foundation.h>
#include "OSObject.h"
#include "OSDevice.h"
#include "OSDFUDevice.h"
#include "OSBinary.h"
#include "OSBinaryMachO.h"

int main(int argc, char** argv) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    OSObject *object = [OSObject alloc];
    NSLog(@"Opaque object at %p", object);
    [object release];

    OSDevice *device = [OSDevice sharedDevice];

    NSLog(@"Device object at %p", device);
    [device retain];
    NSLog(@"Retained, object is at %p", device);

    [device setDefaultsOnDfuString:@"CPID:8940 CPRV:21 CPFM:03 SCEP:01 BDID:08 ECID:000002E9901C9D4C IBFL:00 SRTG:[iBoot-838.3]"];

    OSBinaryMachO *mh_object = [[OSBinaryMachO alloc] init];
    [mh_object mapBinaryWithFilename:"a.out"];
    [mh_object printMachHeader];
    [mh_object printTextSegments]; 
    [pool drain];

    return 0;
}
