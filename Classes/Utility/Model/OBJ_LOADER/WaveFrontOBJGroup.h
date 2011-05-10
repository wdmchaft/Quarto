//
//  WaveFrontOBJGroup.h
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/20/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveFrontOBJTypes.h"
#import "vrTexturePool.h"
//#import "glUtility.h"

@class WaveFrontOBJMaterial;

@interface WaveFrontOBJGroup : NSObject {
	NSArray					*names;
	// we store the data in NSData objects so we can push out the whole
	// stream of bytes at once to the card
	NSMutableData			*vertexIndexData;
	NSMutableData			*normalsIndexData;
	NSMutableData			*textureCoordinatesIndexData;
	WaveFrontOBJMaterial	*material;
	BOOL					smoothing;
	BOOL					isTextured;
	GLuint					indexesName;
	
	NSMutableData			*vertexData;
	GLuint					verticesName;
	NSMutableData			*normalsData;
	GLuint					normalsName;
	NSMutableData			*texCoordsData;
	CFMutableArrayRef		texCoords;
	GLuint					textureCoordsName;
	
	GLuint					vboName; 
	glVBOParam				vboParam;
	GLuint					instanceIDCount;
	
	char					*vboData;
	void					*sortedIndexData;
	int						indexCount;
	
	NSMutableDictionary		*instanceVBOs;
	
	int						faceCount;
	
	float					maxRadius;
	float					rad;
	
	NSString				*key;
}

@property(assign) BOOL smoothing;
@property(retain) NSArray *names;
@property(retain) NSData *vertexIndexData;
@property(readonly) NSData *normalsIndexData;
@property(readonly) NSData *textureCoordinatesIndexData;
@property(retain) WaveFrontOBJMaterial *material;
@property(readonly) BOOL isTextured;
@property(retain) NSString *key;

- (GLuint)indexesName:(GLenum)usage; // the VBO for the indexes

- (GLuint)indexCount;
- (GLuint)texCoordSize; // 1, 2, 3 or 4D textures

//Returns radius of maximum distance vertex on the xy plane.
-(float)radius;

- (void)addVertex:(Vector3D)vertex atIndex:(GLshort)index;
- (void)addNormal:(Vector3D)normal atIndex:(GLshort)index;
- (void)addTexCoord:(Vector2D)coord atIndex:(GLshort)index;

- (void)addVertexIndex:(GLshort)index;
- (void)addNormalIndex:(GLshort)index;
- (void)addTextureCoordinateIndex:(GLshort)index;

- (void)addVertex:(Vector3D)vertex;
- (void)addNormal:(Vector3D)normal;
- (void)addTextureCoordinate:(Vector2D)coord;

-(int)faceCount;
-(void)bindTexture;

- (GLuint)vboName:(GLenum)usage;
- (glVBOParam)vboParam;

-(void)loadFromData:(NSData*)d indexData:(NSData*)i;
-(void)cacheVBOData:(char*)data size:(int)size;

@end
