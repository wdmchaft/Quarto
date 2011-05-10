//
//  WaveFrontOBJScene.h
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/18/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "WaveFrontOBJTypes.h"

#import "WaveFrontOBJGroup.h"
#import "WaveFrontOBJMaterial.h"
#import "WaveFrontOBJTexture.h"

#import "vrTexturePool.h"

#define kMaxInstances 100;


@interface WaveFrontOBJScene : NSObject {
	NSURL			*objURL;
	NSMutableArray	*groups;
	NSDictionary	*materials;
	int				_instanceCount;
	bool			_textureDisabled;
	bool			_enableMaterial;
	WaveFrontOBJGroup *_primaryMesh;
	NSString		*key;
}

-(id)initWithPath:(NSString *)objFilePath key:(NSString*)mkey;
-(id)initWithURL:(NSURL*)objFileURL key:(NSString*)mkey;

-(void)drawSelf;
-(void)preConfigureGroup:(WaveFrontOBJGroup *)group;
-(void)drawGroup:(WaveFrontOBJGroup *)group;
-(void)cleanUp;

@property(retain,nonatomic) NSDictionary	*materials;
@property(retain,nonatomic) NSArray			*groups;
@property(retain,nonatomic) WaveFrontOBJGroup *primaryMesh;
@property(retain,nonatomic) NSString		*key;

@end
