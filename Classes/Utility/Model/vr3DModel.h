//
//  vr3DModel.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 15/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaveFrontOBJScene.h"
#import "WaveFrontOBJGroup.h"
//#import "Model3DS.h"

typedef WaveFrontOBJGroup vrMesh;

@interface vr3DModel : NSObject {
	WaveFrontOBJScene		*_model;
	NSString				*_key;
	NSString				*_textureAtlasFile;
	Texture2D				*_lastTexture;
	//C3DSScene				*_3dsModel;
	bool					_isVRM;
	
	
	int						_faceCount;
	int						_indexCount;
	int						_stride;
	GLuint					_vboName;
	GLuint					_indexesName;
	NSString				*_textureFile;
	GLfloat					_radius;
}

- (id)initWithPath:(NSString *)objFilePath modelKey:(NSString *)key;
- (id)initWithURL:(NSURL*)objFileURL;
-(void)loadFromVRM:(NSString *)key;

- (void)drawSelf;

- (int)meshCount;
- (int)faceCount;
- (void)bindTexture;
-(GLfloat)radius;


-(void)preLoadMesh:(vrMesh *)group;
-(void)drawMesh:(vrMesh *)group;
-(void)drawMeshLines:(vrMesh *)mesh;
-(void)cleanUp;

-(NSString *)modelKey;
-(NSArray *)meshes;
-(vrMesh *)mesh;

@end
