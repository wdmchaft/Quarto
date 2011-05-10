//
//  vrSkyBox.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 31/07/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrSkyBox.h"


@implementation vrSkyBox

-(id)init
{
	self = [super init];
	if(self){
		_texturePositions = [[NSArray alloc] initWithObjects:@"right",@"left",@"front",@"back",@"top",@"bottom",nil];
		//_texturePositions = [[NSArray alloc] initWithObjects:@"right",@"left",@"front",@"back",@"top",nil];

	}
	return self;
}	


-(id)initWithList:(NSString*)plistFile
{
	self = [super init];
	if(self){
		_texturePositions = [[NSArray alloc] initWithObjects:@"right",@"left",@"front",@"back",@"bottom",@"top",nil];
		//_texturePositions = [[NSArray alloc] initWithObjects:@"right",@"left",@"front",@"back",@"top",nil];
		NSString *path = [[NSBundle mainBundle] pathForResource:plistFile ofType:@"plist"];
		_skyboxList = [[NSDictionary alloc] initWithContentsOfFile:path];
		if(!_skyboxList){
			NSLog(@"Error Loading Skybox list.  Aborting.");
			return nil;
		}
		
	}
	return self;
	
}

//Load and release resources.  Populates the _skyboxTextures Dictionary.
-(void)loadSkybox:(NSString*)skyBoxName;
{
	[self loadSkybox:skyBoxName withDepth:kDefaultSkyboxDepth];
}

-(void)loadSkyboxSM:(NSString*)skyBoxName{
	[self loadSkyboxSM:skyBoxName withDepth:kDefaultSkyboxDepth];
}

-(void)loadSkyboxSM:(NSString *)skyBoxName withDepth:(GLfloat)depth
{
	[self setDepth:depth];
	
	[_skyboxTextures release];
	_skyboxTextures= [[NSMutableDictionary alloc] initWithCapacity:6];
	
	NSArray *sbTags = [NSArray arrayWithObjects:@"pos_x",@"neg_x",@"pos_z",@"neg_z",@"pos_y",@"neg_y",nil];
	
	/*****************************************************************************
	/* Load the Texture Files For A SkyMatter Skybox.  
	/* Files are in the format: <name>_<tag>.bmp.pvrtc
	/*****************************************************************************/
	
	for(int i = 0; i<6;i ++)
	{
		NSString *textureFile = [NSString stringWithFormat:@"%@_%@.bmp.pvrtc",
								 skyBoxName,[sbTags objectAtIndex:i]];
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		NSString *position = [_texturePositions objectAtIndex:i];
		
		Texture2D *texture = [[Texture2D alloc] initPRVTextureWithPath:path];
		[_skyboxTextures setObject:texture forKey:position];
		
		if(texture){
			LOG(NSLog(@"Skybox Texture %@ added for Position %@",textureFile, position));
		}
		else {
			NSLog(@"Skybox Texture %@ CREATION FAILED for Position %@",textureFile, position);
		}
		[texture release];
	}
	
}


-(void)loadSkyboxSM2:(NSString *)skyBoxName withDepth:(GLfloat)depth
{
	[self setDepth:depth];
	
	[_skyboxTextures release];
	_skyboxTextures= [[NSMutableDictionary alloc] initWithCapacity:6];
	
	//NSArray *sbTags = [NSArray arrayWithObjects:@"pos_x",@"neg_x",@"pos_z",@"neg_z",@"pos_y",@"neg_y",nil];
	
	int index[6] = {0,2,3,1,4,5};
	
	/*****************************************************************************
	 /* Load the Texture Files For A SkyMatter Skybox.  
	 /* Files are in the format: <name>_<tag>.bmp.pvrtc
	 /*****************************************************************************/
	
	/**********
	 Some skyboxe files start at 0, some at 1... HACK: Check for the 00000 file and assme
	 that if it's not there than the first index is 1
	/**********/
	NSString *textureFile = [NSString stringWithFormat:@"%@_100000.tif.pvrtc",skyBoxName];
	NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
	int k=1; if(path)k=0;
	
	
	
	for(int i = 0; i<6;i ++)
	{
		NSString *textureFile = [NSString stringWithFormat:@"%@_10000%d.tif.pvrtc",
								 skyBoxName,(index[i]+k)];
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		NSString *position = [_texturePositions objectAtIndex:i];
		
		Texture2D *texture = [[Texture2D alloc] initPRVTextureWithPath:path];
		[_skyboxTextures setObject:texture forKey:position];
		
		if(texture){
			LOG(NSLog(@"Skybox Texture %@ added for Position %@",textureFile, position));
		}
		else {
			NSLog(@"Skybox Texture %@ CREATION FAILED for Position %@",textureFile, position);
		}
		[texture release];
	}
	
}


-(void)loadSkybox:(NSString *)skyBoxName withDepth:(GLfloat)depth
{
	[self setDepth:depth];
	
	[_skyboxTextures release];
	_skyboxTextures= [[NSMutableDictionary alloc] initWithCapacity:6];
	
	/*****************************************************************************
	/* Load the Texture Files.  
	/* Files are in the format: <name>000x.tif.pvrtc
	/* Where the <name> is the prefix specified in the skybox generation script
	/* and x denotes the index. 1- front, 2-back, 3-right, 4-left, 5-top, 6-bottom
	/*****************************************************************************/
	
	for(int i = 0; i<6;i ++)
	{
		NSString *textureFile = [NSString stringWithFormat:@"%@000%d.tif.pvrtc",skyBoxName,i+1];
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		NSString *position = [_texturePositions objectAtIndex:i];
		
		Texture2D *texture = [[Texture2D alloc] initPRVTextureWithPath:path];
		[_skyboxTextures setObject:texture forKey:position];
		
		if(texture){
			LOG(NSLog(@"Skybox Texture %@ added for Position %@",textureFile, position));
		}
		else {
			NSLog(@"Skybox Texture %@ CREATION FAILED for Position %@",textureFile, position);
		}
		[texture release];
	}
	
}


-(void)loadSkyboxFromList:(NSString *)skyBoxName withDepth:(GLfloat)depth
{	
	[self setDepth:depth];
	[_skyboxTextures release];
		
	//Load the list of textures from the plist file
	NSDictionary *textureDefs = [[NSDictionary alloc] initWithDictionary:[_skyboxList objectForKey:skyBoxName]];
	if(!textureDefs){
		NSLog(@"Error Loading Skybox Textures List for %@",skyBoxName);
		return;
	}
	
	if(_texturePositions)[_texturePositions release];
	_texturePositions = [[NSArray alloc] initWithArray:[textureDefs allKeys]];
	
	if([_texturePositions count] != 6){
		NSLog(@"Skybox appears to be incomplete!  %d Texture Files Defined",[_texturePositions count]);
	}
	
	_skyboxTextures= [[NSMutableDictionary alloc] init];
	
	for(NSString *position in _texturePositions )
	{
		NSString *textureFile = [[NSString alloc] initWithString:[textureDefs objectForKey:position]];
		NSString *path = [[NSBundle mainBundle] pathForResource:textureFile ofType:nil];
		Texture2D *texture;
		
		NSArray *fnameparts	= [textureFile componentsSeparatedByString:@"."];
		
		gluClearErrors();
		
		if([[fnameparts lastObject] isEqualToString:@"pvrtc"]){
			texture = [[Texture2D alloc] initPRVTextureWithPath:path];
		}
		else{
			texture = [[Texture2D alloc] initWithImagePath:path];
		}
		
		[_skyboxTextures setObject:texture forKey:position];
		
		if(texture){
			LOG(NSLog(@"Skybox Texture %@ added for Position %@",[textureDefs objectForKey:position], position));
		}
		else {
			NSLog(@"Skybox Texture %@ CREATION FAILED for Position %@",[textureDefs objectForKey:position], position);
		}
		
		[texture release];
		[textureFile release];
	}
	
	[textureDefs release];
	
}

-(void)createGeometry:(GLfloat)depth{
	
	//Allocate enough memory for our UVs and Vertices
	if(!_verts)_verts = (GLfloat*)malloc(6*12*sizeof(GLfloat));
	if(!_uvs)_uvs = (GLbyte*)malloc(6*8*sizeof(GLbyte));
	
	//The correction factor is used to eliminate seams between the textures by overlapping
	//them by a few units... Implementation and unit dependent.
	
	const GLfloat cf = kSkyboxCorrectionFactor;
	GLfloat d = depth;
	
	//Vertices and UVS are setup to accept textures generated by
	//TerraGenSkyboxScript.tgs
	GLfloat tvert[72] = {
		-d,+d-cf,+d,  //Front
		+d,+d-cf,+d,
		-d,+d-cf,-d,
		+d,+d-cf,-d,
		+d,-d+cf,+d,  //Back
		-d,-d+cf,+d,
		+d,-d+cf,-d,
		-d,-d+cf,-d,
		+d,+d,-d+cf,  //Top
		+d,-d,-d+cf,
		-d,+d,-d+cf,
		-d,-d,-d+cf,
		+d,+d,+d-cf,  //Bottom
		+d,-d,+d-cf,
		-d,+d,+d-cf,  
		-d,-d,+d-cf,
		-d+cf,-d,+d,  //Left
		-d+cf,+d,+d,
		-d+cf,-d,-d,
		-d+cf,+d,-d,
		+d-cf,+d,+d,  //Right
		+d-cf,-d,+d,
		+d-cf,+d,-d,
		+d-cf,-d,-d};
	memcpy(_verts,tvert,6*12*sizeof(GLfloat));
	
	GLbyte tuv[48] = {
		0, 1,  //Front
		1, 1,
		0, 0,
		1, 0, 
		0, 1,  //Back
		1, 1,
		0, 0,
		1, 0,
		0, 1,  //Right
		1, 1,
		0, 0,
		1, 0,
		1, 0,  //Bottom
		1, 1,
		0, 0,
		0, 1,
		0, 1,  //Left
		1, 1,
		0, 0,
		1, 0,
		0, 1,  //Right
		1, 1,
		0, 0,
		1, 0,
	};
	memcpy(_uvs,tuv,6*8*sizeof(GLbyte));
		
	//TODO: Interleave these as an array of structs
}

-(void)setDepth:(GLfloat)depth
{
	_skyboxDepth = depth;
	[self createGeometry:depth];
}


-(void)render:(Vector3D)origin
{
	[self render:origin angle:0];
}


-(void)render:(Vector3D)origin angle:(float)angle
{
	if(!_skyboxTextures){
		return;
	}
	
	//Assume we're manipulating the ModelView matrix.  Preserve what's on the stack.
	glPushMatrix();
	
	//Translate the center of our cube to our eye position.
	glTranslatef(origin.x, origin.y, origin.z);
	glDisable(GL_LIGHTING);
	
	//Rotate 180 degrees around Y otherwise we render upside down.
	//TODO: Optimize this by pre-multiplying the skybox verts by an appropriate rot matrix.
	glRotatef(180.0f, 0, 1, 0);
	glRotatef(-angle, 0,0,1);
	
	//Disable back-face culling
	glDisable(GL_CULL_FACE);
	glDepthMask(GL_FALSE);

	//Disable normals
	glDisableClientState(GL_NORMAL_ARRAY);
	//Turn on immediate mode.
	//TODO: Optimize this by putting the vertices and UVS in a VBO and interleaving them
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	//Pointer offset for our data.
	uint offset = 0;
		
	for(NSString *position in _texturePositions )
	{
		if([position isEqualToString:@"front"]){
			offset = 0;
		}
		else if([position isEqualToString:@"back"]){
			offset = 1;
		}
		else if([position isEqualToString:@"top"]){
			offset = 2;
		}
		else if([position isEqualToString:@"bottom"]){
			offset = 100;
		}
		else if([position isEqualToString:@"left"]){
			offset = 4;
		}
		else if([position isEqualToString:@"right"]){
			offset = 5;
		}
		
		Texture2D *texture = [_skyboxTextures objectForKey:position];
		if(texture && offset<7){
			glTexCoordPointer(2, GL_BYTE, 0, _uvs+offset*8);
			glBindTexture(GL_TEXTURE_2D,texture.name);
			glVertexPointer(3, GL_FLOAT, 0, _verts+offset*12);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
		
	}
	glDepthMask(GL_TRUE);
	//Clean up and reset state to default
	glEnable(GL_LIGHTING);
	glEnable(GL_CULL_FACE);
	glEnableClientState(GL_NORMAL_ARRAY);
	glPopMatrix();
}


-(void)dealloc
{
	if(_verts)free(_verts);
	if(_uvs)free(_uvs);
	[_skyboxTextures release];
	[_texturePositions	release];
	[super dealloc];
}

@end
