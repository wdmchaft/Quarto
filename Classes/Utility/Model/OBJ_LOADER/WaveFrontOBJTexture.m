//
//  WaveFrontOBJTexture.m
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/20/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import "WaveFrontOBJTexture.h"
#import "Texture2D.h"
#import "PVRTexture.h"
#import "vrTexturePool.h"
#import "vrConstants.h"

@implementation WaveFrontOBJTexture

@synthesize name;
@synthesize textureName;
@synthesize uOffset;
@synthesize vOffset;
@synthesize uSize;
@synthesize vSize;

-(id)init{
	self = [super init];
	if(self){
		vrTexturePool *p = [vrTexturePool sharedvrTexturePool];
		[p addModelTexture:self];
	}
	return self;
}

-(NSString*)textureFile
{
	vrTexturePool *texturePool = [vrTexturePool sharedvrTexturePool];
	if([texturePool isTextureInAtlas:self.name]==TRUE){
		NSDictionary *atlasInfo = [texturePool atlasInfoForTexture:self.name];
		return [atlasInfo objectForKey:@"atlasFile"];
	}
	return self.name;
	
}



- (GLuint)textureName {
	if(0 == textureName) {
		vrTexturePool *texturePool = [vrTexturePool sharedvrTexturePool];
		
		
		//Texture Atlas Support.  Checks the texturePool atlas refs to see if the filename
		//is located in an atlas and grabs the atlas and corresponding UV offsets
		
		if([texturePool isTextureInAtlas:self.name]==TRUE){
			LOG(NSLog(@"Texture %@ Found in an Atlas",self.name));
			isAtlas = TRUE;
			
			texture = [texturePool atlasForTexture:self.name];
			NSDictionary *atlasInfo = [texturePool atlasInfoForTexture:self.name];
			
			self.uOffset	= [[atlasInfo objectForKey:@"uoffset"] floatValue];
			self.vOffset	= [[atlasInfo objectForKey:@"voffset"] floatValue];
			self.uSize		= [[atlasInfo objectForKey:@"usize"] floatValue];
			self.vSize		= [[atlasInfo objectForKey:@"vsize"] floatValue];
			
			LOG(NSLog(@"   Offsets:(%1.2f,%1.2f)  Size:(%1.2f,%1.2f)",uOffset,vOffset,uSize,vSize));
			textureName = texture.name;
			texture = nil;
			return textureName;
			
		}
		
		texture = [texturePool objectForKey:self.name];
		if(texture){
			textureName = texture.name;
			texture = nil;
		}
		else{
			WARN(NSLog(@"OBJ LOADER WARNING: Texture image not found in an atlas... Loading..."));
			NSArray *fnameparts	= [self.name componentsSeparatedByString:@"."];
			if([[fnameparts lastObject] isEqualToString:@"pvrtc"]){
				NSString *path = [[NSBundle mainBundle] pathForResource:self.name ofType:nil];
				texture = [[Texture2D alloc] initPRVTextureWithPath:path];
			}
			else{
				NSString *pvrFname = [NSString stringWithFormat:@"%@.pvrtc",self.name];
				NSString *pvrPath = [[NSBundle mainBundle] pathForResource:pvrFname ofType:nil];
				
				if(pvrPath){
					texture = [[Texture2D alloc] initPRVTextureWithPath:pvrPath];
				}else{
					texture = [[Texture2D alloc] initWithImagePath:self.name];
				}
			}
			textureName = texture.name;
		}
	}
	return textureName;
}

-(BOOL)isAtlas{
	return isAtlas;
}

-(void)dealloc {
	vrTexturePool *p = [vrTexturePool sharedvrTexturePool];
	[p removeModelTexture:self];
	[texture release];
	[name release];
	[super dealloc];
};

@end
