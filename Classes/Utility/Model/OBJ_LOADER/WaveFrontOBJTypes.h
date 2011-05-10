//
//  WaveFrontOBJTypes.h
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/19/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OpenGLCommon.h"


void ReleaseTextureCoord(CFAllocatorRef allocator, const void *value);
const void * RetainTextureCoord(CFAllocatorRef allocator, const void *value);
CFStringRef TextureCoordDescription (const void *value);
