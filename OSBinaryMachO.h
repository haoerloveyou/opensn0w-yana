//
// opensn0w-ng
//
// OSBinaryMachO.h
//

#ifndef _OSBinaryMachO_h_
#define _OSBinaryMachO_h_

#include <Foundation/Foundation.h>
#include "mach-o/loader.h"
#include "OSObject.h"
#include "OSBinary.h"
#include <fcntl.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdint.h>

@interface OSBinaryMachO : OSBinary {
@private
    uint8_t*    mappedFile;
}
-(void)mapBinaryWithFilename:(char*)name;
-(NSDictionary*)getMachHeader;
-(NSDictionary*)getTextSegments;
-(void)printMachHeader;
-(void)printTextSegments;
@end

#endif
