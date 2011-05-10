//
//  vrSkyBox.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 31/07/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "OpenGLCommon.h"
#import "glUtility.h"

#define kDefaultSkyboxDepth		100
#define kSkyboxCorrectionFactor .5f

@interface vrSkyBox : NSObject {
	NSDictionary			*_skyboxList;			//Skybox names pulled from specified plist file
	NSMutableDictionary		*_skyboxTextures;		//Textures - Keyed as Top,Bottom,Left,Right,Front,Back...
	GLfloat					_skyboxDepth;			//Depth of the texture (distance from camera)
	NSArray					*_texturePositions;		//List of position keys in proper order
	GLfloat					*_verts;
	GLbyte					*_uvs;
}


-(id)init;
-(id)initWithList:(NSString*)plistFile;

-(void)loadSkybox:(NSString*)skyBoxName;
-(void)loadSkybox:(NSString*)skyBoxName withDepth:(GLfloat)depth;

-(void)loadSkyboxSM:(NSString*)skyBoxName;
-(void)loadSkyboxSM:(NSString *)skyBoxName withDepth:(GLfloat)depth;

-(void)loadSkyboxSM2:(NSString *)skyBoxName withDepth:(GLfloat)depth;

-(void)loadSkyboxFromList:(NSString *)skyBoxName withDepth:(GLfloat)depth;

-(void)setDepth:(GLfloat)depth;
-(void)createGeometry:(GLfloat)depth;

-(void)render:(Vector3D)origin;
-(void)render:(Vector3D)origin angle:(float)angle;

@end
