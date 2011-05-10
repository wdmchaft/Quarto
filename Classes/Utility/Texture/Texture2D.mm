/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: Texture2D.m
Abstract: Convenience class that allows to create OpenGL 2D textures from images, text or raw data.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "vrConstants.h"
//#import "OpenGL_Internal.h"

/* EAGL and GL functions calling wrappers that log on error */
#define CALL_EAGL_FUNCTION(__FUNC__, ...) ({ EAGLError __error = __FUNC__( __VA_ARGS__ ); if(__error != kEAGLErrorSuccess) printf("%s() called from %s returned error %i\n", #__FUNC__, __FUNCTION__, __error); (__error ? NO : YES); })
#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s\n", __error, __FUNCTION__); (__error ? NO : YES); })

/* Generic error reporting */
#define REPORT_ERROR(__FORMAT__, ...) printf("%s: %s\n", __FUNCTION__, [[NSString stringWithFormat:__FORMAT__, __VA_ARGS__] UTF8String])

//CONSTANTS:

#define kMaxTextureSize		1024

//CLASS IMPLEMENTATIONS:

@implementation Texture2D

@synthesize contentSize=_size, pixelFormat=_format, pixelsWide=_width, pixelsHigh=_height, name=_name, maxS=_maxS, maxT=_maxT;
@synthesize uvOffsets, ignoreBind, isInAtlas;

- (id) initWithTextureID:(GLuint)textureID
{
	self = [super init];
	if(self){
		isInAtlas = TRUE;
		_name = textureID;
	}
	return self;
}

- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	GLint					saveName;
	
	if((self = [super init])) {
		glGenTextures(1, &_name);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, _name);
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		switch(pixelFormat) {
			
			case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
			break;
			
			case kTexture2DPixelFormat_RGBA5551:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
			break;
			
			case kTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
			break;
			
			case kTexture2DPixelFormat_RGB888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_L8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_LA88:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_RGB_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
			break;
			
			case kTexture2DPixelFormat_RGB_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
			break;
			
			case kTexture2DPixelFormat_RGBA_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
			break;
			
			case kTexture2DPixelFormat_RGBA_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
			break;
			
			default:
			[NSException raise:NSInternalInconsistencyException format:@""];
			
		}
		glBindTexture(GL_TEXTURE_2D, saveName);
		
		if(!CHECK_GL_ERROR()) {
			[self release];
			return nil;
		}
		
		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;
	}
	
	return self;
}

- (void) dealloc
{
	if(!_compressedTexture){
		if(_name){
			if(!isInAtlas)glDeleteTextures(1, &_name);
		}
	}else{
		[_compressedTexture release];
	}
	if(_uvs)free(_uvs);
	if(_verts)free(_verts);
	[super dealloc];
}

- (NSString*) description
{
	return nil;//[NSString stringWithFormat:@"<%@ = %08X | Name = %i | Dimensions = %ix%i | Coordinates = (%.2f, %.2f)>", [self class], self, _name, _width, _height, _maxS, _maxT];
}

@end

@implementation Texture2D (Image)

- (id) initPRVTextureWithPath:(NSString*)path
{
	//glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
	[_compressedTexture release];
	_compressedTexture = nil;
	
	_compressedTexture = [[PVRTexture alloc] initWithContentsOfFile:path];
	_name = [_compressedTexture name];
		
	if(_compressedTexture){
		LOG(NSLog(@"Compressed Texture Loaded w. path%@ NAME:%d",path,_name));
	}
	else{
		NSLog(@"TEXTURE2D: Failed to load PVRTC Texture at %@",path);
	}	
	return self;
		
}

- (id) initWithImagePath:(NSString*)path
{
	return [self initWithImagePath:path sizeToFit:NO];
}

- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit
{
	//kTexture2DPixelFormat_Automatic
	return [self initWithImagePath:path sizeToFit:sizeToFit pixelFormat:kTexture2DPixelFormat_Automatic];
}

- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat
{
	UIImage*				uiImage;
	
	if(![path isAbsolutePath])
	path = [[NSBundle mainBundle] pathForResource:path ofType:nil];
	
	uiImage = [[UIImage alloc] initWithContentsOfFile:path];
	self = [self initWithCGImage:[uiImage CGImage] orientation:[uiImage imageOrientation] sizeToFit:sizeToFit pixelFormat:pixelFormat];
	[uiImage release];
	
	if(self == nil)
	REPORT_ERROR(@"Failed loading image at path \"%@\"", path);
	
	return self;
}
	
- (id) initWithCGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned char*			inPixel8;
	unsigned int*			inPixel32;
	unsigned char*			outPixel8;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	
	if(image == nil) {
		[self release];
		return nil;
	}
	
	if(pixelFormat == kTexture2DPixelFormat_Automatic) {
		info = CGImageGetAlphaInfo(image);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if(CGImageGetColorSpace(image)) {
			if(CGColorSpaceGetModel(CGImageGetColorSpace(image)) == kCGColorSpaceModelMonochrome) {
				if(hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 16))
					REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
					REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
			}
			else {
				if((CGImageGetBitsPerPixel(image) == 16) && !hasAlpha)
				pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if(hasAlpha)
					pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGB565;
#if __DEBUG__
						if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 24))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%s\"", path);
#endif
					}
				}
			}		
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
#if __DEBUG__
			if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
			REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
		}
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	switch(orientation) {
		
		case UIImageOrientationUp: //EXIF = 1
		transform = CGAffineTransformIdentity;
		break;
		
		case UIImageOrientationUpMirrored: //EXIF = 2
		transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		break;
		
		case UIImageOrientationDown: //EXIF = 3
		transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
		transform = CGAffineTransformRotate(transform, M_PI);
		break;
		
		case UIImageOrientationDownMirrored: //EXIF = 4
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
		transform = CGAffineTransformScale(transform, 1.0, -1.0);
		break;
		
		case UIImageOrientationLeftMirrored: //EXIF = 5
		transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;
		
		case UIImageOrientationLeft: //EXIF = 6
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;
		
		case UIImageOrientationRightMirrored: //EXIF = 7
		transform = CGAffineTransformMakeScale(-1.0, 1.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;
		
		case UIImageOrientationRight: //EXIF = 8
		transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;
		
		default:
		[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
		
	}
	if((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) || (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
	imageSize = CGSizeMake(imageSize.height, imageSize.width);
	
	width = imageSize.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
		i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
		i *= 2;
		height = i;
	}
	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
#if __DEBUG__
		REPORT_ERROR(@"Image at %ix%i pixels is too big to fit in texture", width, height);
#endif
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {
		
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_RGBA5551:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 2);
		context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_RGB888:
		case kTexture2DPixelFormat_RGB565:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_L8:
		colorSpace = CGColorSpaceCreateDeviceGray();
		data = malloc(height * width);
		context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_A8:
		data = malloc(height * width);
		context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
		break;
		
		case kTexture2DPixelFormat_LA88:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		default:
		[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
		
	}
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		[self release];
		return nil;
	}
	
	if(sizeToFit)
	CGContextScaleCTM(context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
	else {
		CGContextClearRect(context, CGRectMake(0, 0, width, height));
		CGContextTranslateCTM(context, 0, height - imageSize.height);
	}
	if(!CGAffineTransformIsIdentity(transform))
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if(pixelFormat == kTexture2DPixelFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for(i = 0; i < width * height; ++i, ++outPixel16)
		*outPixel16 = *outPixel16 << 1 | 0x0001;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB888) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
		*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
		*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_LA88) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to LA88", NULL);
#endif
	}
	
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Text)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string dimensions:dimensions alignment:alignment font:[UIFont fontWithName:name size:size]];
}


- (id) initWithStringArray:(NSArray*)stringArray dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	//Takes an array of strings and puts them in a long string.
	
	NSUInteger				width,height,i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	
	UIFont *font = [UIFont fontWithName:name size:size];
	
	if(font == nil) {
		REPORT_ERROR(@"Invalid font", NULL);
		[self release];
		return nil;
	}
	
	width = (dimensions.width);
	
	_stringArrayElementWidth	= width;
	width						= width*[stringArray count];
	

	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
			i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
			i *= 2;
		height = i;
	}

	int rows=1;
	if(width > 1024){
		//rows = width/1024;
		//height *= (rows+1);
		NSLog(@"Failed creating texture character string array.  Too many strings");
		return nil;
	}
	
	LOG(NSLog(@"Building Integer String Array Atlas with %d Elements",[stringArray count]));
	LOG(NSLog(@"  ISSTRING Texture size (%d,%d)",width,height));

	
	//colorSpace = CGColorSpaceCreateDeviceGray(); CGColorSpaceRef 
	//data = calloc(height, 2*width);
	//context = CGBitmapContextCreate(data, width, height, 16, 2*width, colorSpace, kCGImageAlphaLast);
	//context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaPremultipliedLast);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	data = calloc(height, width * 4);
	context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(colorSpace);
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		[self release];
		return nil;
	}
	
	if(_stringLocations)[_stringLocations release];
	_stringLocations = [[NSMutableDictionary alloc] initWithCapacity:[stringArray count]];
	
	//CGContextSetGrayFillColor(context, 0, 0);
	//CGContextFillRect(context,CGRectMake(0, 0, dimensions.width, dimensions.height));
	CGContextSetGrayFillColor(context, 1.f, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	
	for(int k=0;k<[stringArray count];k++){
		int xPosition = (_stringArrayElementWidth * k);
		int yPosition = 0;
		NSString *string = [stringArray objectAtIndex:k];
		if([string isEqualToString:@"W"]){
			[string drawInRect:CGRectMake((xPosition), yPosition, (_stringArrayElementWidth), height)
					  withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
		}else{
			[string drawInRect:CGRectMake((xPosition), yPosition, (_stringArrayElementWidth), height)
					  withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];	
		}
		NSNumber *xPos = [NSNumber numberWithInt:k];
		[_stringLocations setObject:xPos forKey:string];
		//NSLog(@"  ADDED STRING:%@ at (%d,%d) For Index:%d",string,xPosition,0,k);
	}
		
	_uWidth = (float)_stringArrayElementWidth/(float)width;
	_vHeight = (float)height/(float)rows;
	//NSLog(@"  Character Width: %1.5f",_uWidth);
	
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_RGBA8888 pixelsWide:width pixelsHigh:height contentSize:CGSizeMake(width,height)];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}



- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	
	if(font == nil) {
		REPORT_ERROR(@"Invalid font", NULL);
		[self release];
		return nil;
	}
	
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
		i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
		i *= 2;
		height = i;
	}
	
	//colorSpace = CGColorSpaceCreateDeviceGray(); CGColorSpaceRef 
	//data = calloc(height, 2*width);
	//context = CGBitmapContextCreate(data, width, height, 16, 2*width, colorSpace, kCGImageAlphaLast);
	//context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaPremultipliedLast);

	colorSpace = CGColorSpaceCreateDeviceRGB();
	data = calloc(height, width * 4);
	context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(colorSpace);
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		[self release];
		return nil;
	}
	
	
	//CGContextSetGrayFillColor(context, 0, 0);
	//CGContextFillRect(context,CGRectMake(0, 0, dimensions.width, dimensions.height));
	CGContextSetGrayFillColor(context, 1.f, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_RGBA8888 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Drawing)

- (void) preload
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	[self drawInRect:CGRectMake(-2, -2, 0.1, 0.1)];
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
}

- (void) drawAtPoint:(CGPoint)point
{
	[self drawAtPoint:point depth:0.0];
}

- (void) drawAtPoint:(CGPoint)point depth:(CGFloat)depth
{
	GLfloat				coordinates[] = {
							0,				_maxT,
							_maxS,			_maxT,
							0,				0,
							_maxS,			0
						};
	GLfloat				width = (GLfloat)_width * _maxS,
						height = (GLfloat)_height * _maxT;
	GLfloat				vertices[] = {
							-width / 2 + point.x,		-height / 2 + point.y,		depth,
							width / 2 + point.x,		-height / 2 + point.y,		depth,
							-width / 2 + point.x,		height / 2 + point.y,		depth,
							width / 2 + point.x,		height / 2 + point.y,		depth
						};
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect
{
	[self drawInRect:rect depth:-2.0];
}

- (void) drawInRect:(CGRect)rect depth:(CGFloat)depth
{
	GLfloat *coordinates;
	
	//NB: Texture Co-ords Modifed to render in "backbutton-to-left" landscape
	GLfloat coordinates1[] = {
								0.01,			0.01,
								0.01,			_maxT,
								_maxS,			0.01,					
								_maxS,			_maxT,
		
		};
	
	GLfloat uOffset = uvOffsets.origin.x;
	GLfloat vOffset = uvOffsets.origin.y;
	GLfloat uSize	= uvOffsets.size.width;
	GLfloat vSize	= uvOffsets.size.height;
	
	float cf = .001;
	
	GLfloat coordinates2[] = {
					uOffset+cf,			vOffset+vSize-cf,
					uOffset+cf,			vOffset+cf,
					uOffset+uSize-cf,		vOffset+vSize-cf,					
					uOffset+uSize-cf,			vOffset+cf,
		 };
	
	
	if(isInAtlas)coordinates = coordinates2;
	else coordinates = coordinates1;

	GLfloat				vertices[] = {
							rect.origin.x,							rect.origin.y,							depth,
							rect.origin.x + rect.size.width,		rect.origin.y,							depth,
							rect.origin.x,							rect.origin.y + rect.size.height,		depth,
							rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		depth
						};
	

	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
}


//For a bunch of textures in the same atlas, returns a vertex and UV array for a triangle
//strip to draw the whole lot in one call given the rects and the Texture2D pointers.
//Populates pre-allocated arrays...
+(void)createStripFromRects:(CGRect *)rects textures:(NSArray *)textures colours:(Color3D *)colors arrays:(vrStripDef)ret
{
	//int count = [textures count];
	//vrStripDef ret;
	
	//ret.verts	= (Vertex3D *)malloc(6*count*sizeof(Vertex3D));
	//ret.uvs	= (UVVertex2D *)malloc(6*count*sizeof(UVVertex2D));
	//ret.colors= (Color3D *)malloc(6*count*sizeof(Color3D));
	//ret.count	= 6*count;
	
	int index=0, quadCount=0;
	const float depth = -2;
	const float cf = .001;
	
	for(Texture2D *t in textures){
		GLfloat uOffset = t.uvOffsets.origin.x;
		GLfloat vOffset = t.uvOffsets.origin.y;
		GLfloat uSize	= t.uvOffsets.size.width;
		GLfloat vSize	= t.uvOffsets.size.height;
		
		CGRect rect = rects[quadCount];
		
		ret.uvs[index]		= UVVertex2DMake(uOffset+cf,	vOffset+vSize-cf);	
		ret.uvs[index+1]	= ret.uvs[index];
		ret.uvs[index+2]	= UVVertex2DMake(uOffset+cf,	vOffset+cf);		
		ret.uvs[index+3]	= UVVertex2DMake(uOffset+uSize-cf,	vOffset+vSize-cf);	
		ret.uvs[index+4]	= UVVertex2DMake(uOffset+uSize-cf,	vOffset+cf);	
		ret.uvs[index+5]	= ret.uvs[index+4];
		
		ret.verts[index]	= Vertex3DMake(rect.origin.x, rect.origin.y, depth);
		ret.verts[index+1]	= ret.verts[index];
		ret.verts[index+2]	= Vertex3DMake(rect.origin.x + rect.size.width, rect.origin.y, depth);
		ret.verts[index+3]	= Vertex3DMake(rect.origin.x, rect.origin.y+rect.size.height, depth);
		ret.verts[index+4]	= Vertex3DMake(rect.origin.x + rect.size.width, rect.origin.y+rect.size.height, depth);
		ret.verts[index+5]	= ret.verts[index+4];
		
		if(colors)for(int i=0;i<6;i++)ret.colors[index+i]=colors[quadCount];
		
		quadCount++;
		index+=6;
	}	
}



//For a bunch of textures in the same atlas, returns a vertex and UV array for a triangle
//strip to draw the whole lot in one call given the rects and the Texture2D pointers.
//Returns freshly allocated arrays.
+(vrStripDef)createStripFromRects:(CGRect *)rects textures:(NSArray *)textures colours:(Color3D *)colors;
{
	int count = [textures count];
	vrStripDef ret;
	
	ret.verts	= (Vertex3D *)malloc(6*count*sizeof(Vertex3D));
	ret.uvs		= (UVVertex2D *)malloc(6*count*sizeof(UVVertex2D));
	ret.colors	= (Color3D *)malloc(6*count*sizeof(Color3D));
	ret.count	= 6*count;
	
	int index=0, quadCount=0;
	const float depth = -2;
	const float cf = .001;

	for(Texture2D *t in textures){
		GLfloat uOffset = t.uvOffsets.origin.x;
		GLfloat vOffset = t.uvOffsets.origin.y;
		GLfloat uSize	= t.uvOffsets.size.width;
		GLfloat vSize	= t.uvOffsets.size.height;
		
		CGRect rect = rects[quadCount];
		
		ret.uvs[index]		= UVVertex2DMake(uOffset+cf,	vOffset+vSize-cf);	
		ret.uvs[index+1]	= ret.uvs[index];
		ret.uvs[index+2]	= UVVertex2DMake(uOffset+cf,	vOffset+cf);		
		ret.uvs[index+3]	= UVVertex2DMake(uOffset+uSize-cf,	vOffset+vSize-cf);	
		ret.uvs[index+4]	= UVVertex2DMake(uOffset+uSize-cf,	vOffset+cf);	
		ret.uvs[index+5]	= ret.uvs[index+4];

		ret.verts[index]	= Vertex3DMake(rect.origin.x, rect.origin.y, depth);
		ret.verts[index+1]	= ret.verts[index];
		ret.verts[index+2]	= Vertex3DMake(rect.origin.x + rect.size.width, rect.origin.y, depth);
		ret.verts[index+3]	= Vertex3DMake(rect.origin.x, rect.origin.y+rect.size.height, depth);
		ret.verts[index+4]	= Vertex3DMake(rect.origin.x + rect.size.width, rect.origin.y+rect.size.height, depth);
		ret.verts[index+5]	= ret.verts[index+4];
		
		quadCount++;
		index+=6;
	}	
	return ret;
}



@end
