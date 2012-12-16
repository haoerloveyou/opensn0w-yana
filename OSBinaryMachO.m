//
// opensn0w-ng
//
// OSBinaryMachO.m
//

#include "OSBinaryMachO.h"

@implementation OSBinaryMachO

-(void)mapBinaryWithFilename:(char*)name {
    int fd;
    struct stat st;
    void *p;

    fd = open(name, O_RDONLY);
    if(fd == -1)
        return;
    if(fstat(fd, &st) != 0)
        return;

    p = mmap(0, st.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
    if(!p)
        return;

    mappedFile = (uint8_t*)p;
}

-(NSDictionary*)getMachHeader {
    struct mach_header* mh_head = (struct mach_header*)mappedFile;
    NSMutableDictionary* dict = [NSMutableDictionary alloc];

    if(mh_head == NULL) {
        NSLog(@"Null mach header, did you forget to map the file?");
        return nil;
    }

    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->magic] forKey:@"magic"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->cputype] forKey:@"cputype"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->cpusubtype] forKey:@"cpusubtype"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->filetype] forKey:@"filetype"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->ncmds] forKey:@"ncmds"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->sizeofcmds] forKey:@"sizeofcmds"];
    [dict setObject:[NSNumber numberWithUnsignedLong:mh_head->flags] forKey:@"flags"];

    return dict;
}

-(void)printMachHeader {
    NSLog(@"%@", [self getMachHeader]);
}

-(void)printTextSegments {
    NSLog(@"%@", [self getTextSegments]);
}

-(NSDictionary*)getTextSegments {
    struct mach_header* mh_head = (struct mach_header*)mappedFile;
    NSMutableDictionary* dict = [NSMutableDictionary alloc];
    int i;
    uint8_t *p = mappedFile;

    if(mh_head == NULL) {
        NSLog(@"Null mach header, did you forget to map the file?");
        return nil;
    }

    p += sizeof(struct mach_header);

    for(i = 0; i < mh_head->ncmds; i++) {
        struct load_command* ld_cmd = (struct load_command*)p;
        switch(ld_cmd->cmd) {
            case LC_SEGMENT: {
                int x;
                uint8_t *p2 = p;
                struct segment_command* seg = (struct segment_command*)p;
                NSMutableDictionary *dictionary = [NSMutableDictionary alloc];
                [dictionary setObject:[NSString stringWithUTF8String:seg->segname]
                            forKey:@"segname"];
                [dictionary setObject:[NSNumber numberWithUnsignedLong:seg->vmaddr]
                            forKey:@"vmaddr"];
                [dictionary setObject:[NSNumber numberWithUnsignedLong:seg->fileoff]
                            forKey:@"fileoff"];
                [dictionary setObject:[NSNumber numberWithUnsignedLong:seg->filesize]
                            forKey:@"filesize"];
                if(seg->nsects) {
                    for(x = 0; x < seg->nsects; x++) {
                        NSMutableDictionary *sectDict = [NSMutableDictionary alloc];
                        struct section *sect = (struct section*)(p2 + sizeof(struct segment_command));
                        [sectDict setObject:[NSString stringWithUTF8String:sect->sectname]
                                  forKey:@"sectname"];
                        [sectDict setObject:[NSString stringWithUTF8String:sect->segname]
                                  forKey:@"segname"];
                        [sectDict setObject:[NSNumber numberWithUnsignedLong:sect->addr]
                                  forKey:@"addr"];
                        [sectDict setObject:[NSNumber numberWithUnsignedLong:sect->size]
                                  forKey:@"size"];
                        [sectDict setObject:[NSNumber numberWithUnsignedLong:sect->offset]
                                  forKey:@"offset"];
                        [dictionary setObject:sectDict forKey:[NSString stringWithFormat:@"section,%d", x]];
                        [sectDict release];
                        p2 += sizeof(struct section);
                    }
                }
                [dict setObject:dictionary forKey:[NSString stringWithFormat:@"ld_cmd,%d", i]];
                [dictionary release];
                break;
            }
            default:
                break;
        }
        p += ld_cmd->cmdsize;
    }

    return dict;
}

@end
