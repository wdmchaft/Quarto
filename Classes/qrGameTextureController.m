//
//  qrGameTextureController.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-29.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrGameTextureController.h"


@implementation qrGameTextureController

-(id)init
{
	self = [super init];
	if(self){
		_texturesLoaded = YES;
	}
	return self;
}

-(void)loadTexturesFromPlist:(NSString *)plist
{
	if(!_loadedTextures)_loadedTextures = [[NSMutableDictionary alloc] init];
	
	NSString *textureDefs = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
	NSDictionary *textures = [[NSDictionary alloc] initWithContentsOfFile:textureDefs];
	
	vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
	NSDictionary *new = [tp loadTexturesFromDictionary:textures];
	
	[_loadedTextures addEntriesFromDictionary:new];
}

-(void)freeAllTextureMemory
{
	vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
	for(NSString *key in _loadedTextures)
	{
		[tp removeTextureForKey:key];
	}
	_texturesLoaded = NO;
}


-(void)restoreTextures
{
	if(!_texturesLoaded){
		vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
		[tp loadTexturesFromDictionary:_loadedTextures];
	}
	_texturesLoaded = YES;
}

@end
