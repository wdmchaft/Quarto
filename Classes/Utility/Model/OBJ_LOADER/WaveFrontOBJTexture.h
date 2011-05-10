//
//  WaveFrontOBJTexture.h
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/20/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveFrontOBJTypes.h"

@class Texture2D;

@interface WaveFrontOBJTexture : NSObject {
	NSString	*name;			// file name of image for ambient
	Texture2D	*texture;
	GLuint		textureName;
	BOOL		blendu;
	BOOL		blendv;
	BOOL		clamp;

	//Texture Atlas Support:
	GLfloat			uOffset;
	GLfloat			vOffset;
	GLfloat			uSize;
	GLfloat			vSize;
	BOOL			isAtlas;
}

@property(retain) NSString *name;
@property(assign) GLuint textureName;
@property(assign) GLfloat uOffset;
@property(assign) GLfloat vOffset;
@property(assign) GLfloat uSize;
@property(assign) GLfloat vSize;


- (GLuint)textureName;
-(NSString*)textureFile;
- (BOOL)isAtlas;


@end
