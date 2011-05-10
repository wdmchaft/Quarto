/*
 *  HackChecker.c
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 10-03-18.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */

#include "HackChecker.h"
#include <stdio.h>

/* The encryption info struct and constants are missing from the iPhoneSimulator SDK, but not from the iPhoneOS or
 * Mac OS X SDKs. Since one doesn't ever ship a Simulator binary, we'll just provide the definitions here. */
#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command {
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t cryptoff;
    uint32_t cryptsize;
    uint32_t cryptid;
};
#endif

bool is_encrypted(){
    const struct mach_header *header;
    Dl_info dlinfo;
	
    /* Fetch the dlinfo for main() */
    if (dladdr(main, &dlinfo) == 0 || dlinfo.dli_fbase == NULL) {
        printf("Could not find main() symbol (very odd) \n");
        return false;
    }
    header = dlinfo.dli_fbase;
	
    /* Compute the image size and search for a UUID */
    struct load_command *cmd = (struct load_command *) (header+1);
	
    for (uint32_t i = 0; cmd != NULL && i < header->ncmds; i++) {
        /* Encryption info segment */
        if (cmd->cmd == LC_ENCRYPTION_INFO) {
            struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
            /* Check if binary encryption is enabled */
            if (crypt_cmd->cryptid < 1) {
                /* Disabled, probably pirated */
                return false;
            }
			
            /* Probably not pirated? */
            return true;
        }
		
        cmd = (struct load_command *) ((uint8_t *) cmd + cmd->cmdsize);
    }
	
    /* Encryption info not found */
    return false;
}