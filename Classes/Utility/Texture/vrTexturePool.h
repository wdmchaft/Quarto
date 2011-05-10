//
//  vrTexturePool.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//


/***********************************************************************/
/* Singleton "Pool" Object to Hold A
/* Global Set of reusable textures
/* 
/* Note: Textures persist in here for the life of the app for performance. 
/* 
/***********************************************************************/ 

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "SynthesizeSingleton.h"
#import "vrConstants.h"
#import "WaveFrontOBJTexture.h"


@interface vrTexturePool : NSObject {
	NSMutableDictionary		*_texturePool;
	NSMutableDictionary		*_atlasReference;
	NSDictionary			*_atlasTextureRefs;
	NSMutableDictionary		*_atlasTextures;
	
	NSMutableArray			*_modelTextures;
	
	bool					optimizeBindings;
	
	GLuint					_lastRequested;
	int						_bindCalls;
	
	GLuint					lastBinding;
}

@property bool optimizeBindings;
@property(nonatomic) GLuint lastBinding;

+(vrTexturePool*)sharedvrTexturePool;
-(NSMutableDictionary *)getPool;
-(NSDictionary *)loadTexturesFromDictionary:(NSDictionary *)textures;

-(void)addTexture:(id)texture withKey:(NSString *)key;
-(void)removeTextureForKey:(NSString *)key;


-(id)objectForKey:(NSString *)key;
-(void)replaceAtlasWithKey:(NSString*)key withTextureFile:(NSString *)fname;
-(bool)textureExistsWithKey:(NSString *)key;
-(void)replaceBaseAtlasWithKey:(NSString *)key withFile:(NSString*)textureFile;
-(GLuint)textureIDForKey:(NSString*)key;
-(GLuint)atlasTextureIDForKey:(NSString *)key;

-(void)addModelTexture:(WaveFrontOBJTexture *)texture;
-(bool)removeModelTexture:(WaveFrontOBJTexture *)texture;

//Texture Atlas Support
-(void)loadTextureAtlasDefs:(NSString*)fname;			//Load list of atlasses from txt file
-(void)loadAtlasses:(NSArray*)files;						//Load a specific atlas
-(void)freeUnused;										//Check to see if any atlasses are unused and unload them
-(NSDictionary*)atlasInfoForTexture:(NSString *)fname;	//Given a specific file name, return the atlas data - should also load the atlas
-(BOOL)isTextureInAtlas:(NSString *)fname;
-(Texture2D *)atlasForTexture:(NSString *)fname;

-(int)bindCallCount;
-(void)bindCallMade;

//Support to eliminate rebinding textures
-(GLuint)lastBoundTextureID;
-(void)setLastBoundTextureID:(GLuint)textureID;



@end
