//
//  vrTexturePool.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrTexturePool.h"


@implementation vrTexturePool

@synthesize optimizeBindings;
@synthesize lastBinding;

SYNTHESIZE_SINGLETON_FOR_CLASS(vrTexturePool)

-(NSMutableDictionary *)getPool
{
	if(!_texturePool)_texturePool = [[NSMutableDictionary alloc] init];
	return _texturePool;
}

/****************************************************************************/
/* Container of references to WaveFontOBJTexture objects created			*/
/*    by our OBJ loader.  These "skins" contain a reference to a			*/
/*    textureID and thus must be updated if we ever replace a texture...	*/
/****************************************************************************/

-(void)addModelTexture:(WaveFrontOBJTexture *)texture
{
	if(!_modelTextures)_modelTextures = [[NSMutableArray alloc] init];
	[_modelTextures addObject:texture];
}
	
-(bool)removeModelTexture:(WaveFrontOBJTexture *)texture
{
	bool removed = FALSE;
	removed = [_modelTextures containsObject:texture];
	if(removed)[_modelTextures removeObject:texture];
	return removed;
}

/****************************************************************************/


-(NSDictionary *)loadTexturesFromDictionary:(NSDictionary *)textures
{
	Texture2D *texture;
	
	NSMutableDictionary *ret = [[[NSMutableDictionary alloc] init] autorelease];
	
	for(NSString *key in textures){
		NSString *textureFile = [textures objectForKey:key];
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		NSArray *fNameParts = [textureFile componentsSeparatedByString:@"."];
		
		NSString *fType = [fNameParts lastObject];
		
		if([fType isEqualToString:@"pvrtc"] || [fType isEqualToString:@"pvr"])
		{
			texture = [[Texture2D alloc] initPRVTextureWithPath:path];
			if(texture)LOG(NSLog(@"Loaded %@ Texture with key: %@",fType,key));
		}else{
			texture = [[Texture2D alloc] initWithImagePath:path];
			if(texture)LOG(NSLog(@"Loaded %@ Texture with key: %@",fType,key));
		}	
		
		if(texture){
			[self addTexture:texture withKey:key];
			[ret setObject:textureFile forKey:key];
		}
		else NSLog(@"Error Loading Texture %@",textureFile);		
		
		[texture release];
	}
	return ret;
}	


-(void)addTexture:(id)texture withKey:(NSString *)key
{
	if(!_texturePool)_texturePool = [[NSMutableDictionary alloc] init];
	[_texturePool setObject:texture forKey:key];
}

-(void)replaceAtlasWithKey:(NSString*)key withTextureFile:(NSString *)textureFile
{
	
	Texture2D *originalTexture = [_atlasTextures objectForKey:key];
	
	if(!originalTexture){
		NSLog(@"TEXTUREPOOL REPLACE ERROR: Attempted replaceing a texture that doesn't exist with key %@",key);
		return;
	}
	
	GLuint originalTextureName = originalTexture.name;
	if([originalTexture retainCount] != 1){
		NSLog(@"TEXTUREPOOL REPLACE ERROR: Texture is retained elsewhere. Aborting");
		return;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
	if(!path){
		NSLog(@"TEXTUREPOOL REPLACE ERROR: New Texture %@ not found",textureFile);
		return;
	}
	
	[_atlasTextures removeObjectForKey:key];
	//[originalTexture release];
	originalTexture = nil;
	
	Texture2D *newTexture;
	
	NSArray *fnameparts	= [textureFile componentsSeparatedByString:@"."];
	if([[fnameparts lastObject] isEqualToString:@"pvrtc"]){
		newTexture = [[Texture2D alloc] initPRVTextureWithPath:path];
	}
	else{
		newTexture = [[Texture2D alloc] initWithImagePath:textureFile];
	}
	
	if(newTexture){
		[_atlasTextures setObject:newTexture forKey:key];
		[newTexture release];
		LOG(NSLog(@"TEXTUREPOOL REPLACE: Added Texture:%@ to replace %@",textureFile,key));
		
		int c = 0;
		for(NSString *key in _texturePool){
			Texture2D *t = [_texturePool objectForKey:key];
			if(t.name == originalTextureName){
				t.name = newTexture.name;
				c++;
			}
		}
		for(WaveFrontOBJTexture *t in _modelTextures){
			if(t.textureName == originalTextureName){
				t.textureName = newTexture.name;
				c++;
			}
		}
		
		LOG(NSLog(@"TEXTUREPOOL REPLACE: Changed TextureID for %d textures",c));
	}
	else {
		NSLog(@"FATAL ERROR: Could not Create Replacement Texture:%@",textureFile);
	}
}

-(void)removeTextureForKey:(NSString *)key
{
	[_texturePool removeObjectForKey:key];
	NSLog(@"Removed Texture with Key %@",key);
}

-(id)objectForKey:(NSString *)key
{
	Texture2D *texture = [_texturePool objectForKey:key];
	return texture;
}

-(bool)textureExistsWithKey:(NSString *)key
{
	if([_texturePool objectForKey:key])return true;
	return false;
}

-(int)bindCallCount{
	int b = _bindCalls;
	_bindCalls = 0;
	return b;
}

-(void)bindCallMade{
	_bindCalls++;
}

//Texture Atlas Support

-(void)loadTextureAtlasDefs:(NSString*)fname{
	//Load list of atlasses from txt file
	if(!_atlasReference)_atlasReference = [[NSMutableDictionary alloc] init];
	
	NSString *atlasInfo = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fname ofType:NULL] encoding:NSASCIIStringEncoding error:NULL];
	if(!atlasInfo){
		//NSLog(@"Texture Atlas Definitions Not Found, Aborting...");
		return;
	}
	
	NSArray *lines = [atlasInfo	componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSString *atlasFile;
	
	for(NSString *line in lines){
		NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if([[components objectAtIndex:0] isEqualToString:@"fileName"]){
			atlasFile = [components objectAtIndex:1];
		}
	}
	
	if(atlasFile)LOG(NSLog(@"Found Altas File Def: %@",atlasFile));
	if(!atlasFile)NSLog(@"ERROR: NO TEXTURE ATLAS FILE SPECIFIED!  About to crash...");
	
	for (NSString *line in lines)
	{
		NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

		if([components count] == 7){
			NSString *fname		= [components objectAtIndex:0];
			float uo			= [[components objectAtIndex:1] floatValue];
			NSNumber *uoffset	= [NSNumber numberWithFloat:uo];
			float vo			= [[components objectAtIndex:2] floatValue];
			NSNumber *voffset	= [NSNumber numberWithFloat:vo];
			float us			= [[components objectAtIndex:3] floatValue];
			NSNumber *usize		= [NSNumber numberWithFloat:us];
			float vs			= [[components objectAtIndex:4] floatValue];
			NSNumber *vsize		= [NSNumber numberWithFloat:vs];
			NSString *page		= [components objectAtIndex:5];

			NSMutableDictionary *textureDef = [[NSMutableDictionary alloc] init];
			
			[textureDef setObject:fname forKey:@"filename"];
			[textureDef setObject:uoffset forKey:@"uoffset"];
			[textureDef setObject:voffset forKey:@"voffset"];
			[textureDef setObject:usize forKey:@"usize"];
			[textureDef setObject:vsize forKey:@"vsize"];
			[textureDef setObject:page forKey:@"page"];
			[textureDef setObject:atlasFile forKey:@"atlasFile"];
			
			[_atlasReference setObject:textureDef forKey:fname];
			
			LOG(NSLog(@"ATLAS LOAD: Texture:%@ Mapped To Atlas:%@",fname,page));
			[textureDef release];
			
			//Automatically create dictionary entries using the first part of the 
			//filename
			
			NSArray *fnameParts = [fname componentsSeparatedByString:@"."];
			NSString *key = [fnameParts objectAtIndex:0];
			
			Texture2D *texture = [_atlasTextures objectForKey:atlasFile];
			CGRect uvOffsets	= CGRectMake(uo,vo,us,vs);
			
			Texture2D *bg = [[Texture2D alloc] initWithTextureID:texture.name];
			bg.uvOffsets = uvOffsets;
			[self addTexture:bg withKey:key];
			[bg release];
			
		}
	}
	
}	
	
-(void)loadAtlasses:(NSArray*)files{
	if(!_atlasTextures)_atlasTextures = [[NSMutableDictionary alloc] init];
	
	for(NSString *file in files)
	{
		NSString *textureFile = file;
		
		Texture2D *atlasTexture;// = [[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:textureFile ofType:NULL]];
		bool isPvr = false;
		NSArray *fnameparts	= [textureFile componentsSeparatedByString:@"."];
		if([[fnameparts lastObject] isEqualToString:@"pvrtc"] || [[fnameparts lastObject] isEqualToString:@"pvr"]){
			isPvr = true;
			NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
			atlasTexture = [[Texture2D alloc] initPRVTextureWithPath:path];
		}
		else{
			atlasTexture = [[Texture2D alloc] initWithImagePath:textureFile];
		}
		
		if(atlasTexture){
			[_atlasTextures setObject:atlasTexture forKey:textureFile];
			if(isPvr){
				NSArray *parts = [textureFile componentsSeparatedByString:@".pvr"];
				NSString *pngName = [parts objectAtIndex:0];
				[_atlasTextures setObject:atlasTexture forKey:pngName];
				LOG(NSLog(@"Aliasing PVR texture: %@",pngName));
			}
			//[_atlasTextures setObject:atlasTexture forKey:key];
			[atlasTexture release];
			LOG(NSLog(@"ATLAS LOAD: Added Texture Atlas:%@",textureFile));
		}
		else {
			NSLog(@"ERROR: Could not load Atlas:%@",textureFile);
		}
	}
}


-(void)freeUnused{
	//Check to see if any atlasses are unused and unload them
}

-(NSDictionary*)atlasInfoForTexture:(NSString *)fname{
	//Given a specific file name, return the atlas data
	NSDictionary *atlasInfo = [_atlasReference objectForKey:fname];
	return atlasInfo;
}

-(GLuint)atlasTextureIDForKey:(NSString *)key
{
	Texture2D *t;
	t = [_atlasTextures objectForKey:key];
	return t.name;
}	
	
-(GLuint)textureIDForKey:(NSString*)key
{
	Texture2D *t;
	
	t = [_texturePool objectForKey:key];
	if(t)return t.name;
	
	NSLog(@"ERROR: Can't find texture for key: %@",key);
	return 0;
	
}


-(Texture2D *)atlasForTexture:(NSString *)fname{
	NSDictionary *atlasDef = [_atlasReference objectForKey:fname];
	NSString* atlasFile = [atlasDef objectForKey:@"atlasFile"];
	Texture2D *texture = [_atlasTextures objectForKey:atlasFile];
	
	return texture;
}


-(BOOL)isTextureInAtlas:(NSString *)fname{
	NSDictionary *atlasDef = [_atlasReference objectForKey:fname];
	NSString* atlasFile = [atlasDef objectForKey:@"atlasFile"];
	
	Texture2D *texture = [_atlasTextures objectForKey:atlasFile];
	if(texture)return TRUE;
	return FALSE;
}


-(void)replaceBaseAtlasWithKey:(NSString *)key withFile:(NSString*)textureFile
{
	
	Texture2D *originalTexture = [[_atlasTextures objectForKey:key] retain];
	
	if(!originalTexture){
		NSLog(@"ATLAS REPLACE: Attempted removing an atlas that doesn't exist with key %@",key);
		return;
	}
	
	Texture2D *newTexture;// = [[Texture2D alloc] initWithImagePath:[[NSBundle mainBundle] pathForResource:textureFile ofType:NULL]];
	
	NSArray *fnameparts	= [textureFile componentsSeparatedByString:@"."];
	if([[fnameparts lastObject] isEqualToString:@"pvrtc"]){
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		newTexture = [[Texture2D alloc] initPRVTextureWithPath:path];
	}
	else{
		newTexture = [[Texture2D alloc] initWithImagePath:textureFile];
	}
	
	if(newTexture){
		[originalTexture release];
		[_atlasTextures setObject:newTexture forKey:key];
		//[_atlasTextures setObject:atlasTexture forKey:key];
		[newTexture release];
		NSLog(@"ATLAS REPLACE: Added Texture Atlas:%@ to replace %@",textureFile,key);
	}
	else {
		NSLog(@"ATLAS REPLACE: Could not load Atlas:%@",textureFile);
		[_atlasTextures setObject:originalTexture forKey:key];
		[originalTexture release];
	}
}


-(GLuint)lastBoundTextureID{
	return _lastRequested;
}

-(void)setLastBoundTextureID:(GLuint)textureID{
	_lastRequested = textureID;
}

-(void)dealloc
{
	[_texturePool release];
	[_atlasReference release];
	[_atlasTextureRefs release];
	[super dealloc];
}

@end
