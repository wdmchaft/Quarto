//
//  WaveFrontOBJGroup.m
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/20/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import "WaveFrontOBJGroup.h"
#import "WaveFrontOBJTexture.h"
#import "WaveFrontOBJMaterial.h"
#import "glUtility.h"


@implementation WaveFrontOBJGroup

@synthesize smoothing;
@synthesize names;
@synthesize vertexIndexData;
@synthesize normalsIndexData;
@synthesize textureCoordinatesIndexData;
@synthesize material;
@synthesize isTextured;
@synthesize key;

- (id)init {
	self = [super init];
	if(nil != self) {
		vertexIndexData = [[NSMutableData alloc] init];
		normalsIndexData = [[NSMutableData alloc] init];
		textureCoordinatesIndexData = [[NSMutableData alloc] init];
		vertexData = [[NSMutableData alloc] init];
		normalsData = [[NSMutableData alloc] init];
		texCoordsData = [[NSMutableData alloc] init];
		instanceVBOs = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (NSUInteger)indexCount {
	return indexCount;
	//return [vertexIndexData length] / sizeof(GLshort);
}

- (GLuint)texCoordSize { 
	return sizeof(Vector2D);
}

-(float)radius{
	if(!rad)rad = sqrtf(maxRadius);
	return rad;
}

- (void)addVertex:(Vector3D)vertex atIndex:(GLshort)index {
	[self addVertexIndex:(GLshort)([vertexData length] / sizeof(Vector3D))];
	[self addVertex:vertex];
	float max = vertex.x*vertex.x+vertex.y*vertex.y;
	if(max > maxRadius)maxRadius = max;
}

- (void)addNormal:(Vector3D)normal atIndex:(GLshort)index {
	[self addNormalIndex:(GLshort)([normalsData length] / sizeof(Vector3D))];
	[self addNormal:normal];
}

- (void)addTexCoord:(Vector2D)coord atIndex:(GLshort)index {
	[self addTextureCoordinateIndex:(GLshort)([texCoordsData length] / sizeof(Vector2D))];
	[self addTextureCoordinate:coord];
}

- (void)addVertexIndex:(GLshort)index {
	[vertexIndexData appendBytes:&index length:sizeof(GLshort)];
}

- (void)addNormalIndex:(GLshort)index {
	[normalsIndexData appendBytes:&index length:sizeof(GLshort)];
}

- (void)addTextureCoordinateIndex:(GLshort)index {
	[textureCoordinatesIndexData appendBytes:&index length:sizeof(GLshort)];
}

- (void)addVertex:(Vector3D)vertex {
	[vertexData appendBytes:&vertex length:sizeof(Vector3D)];
}

- (void)addNormal:(Vector3D)vertex {
	[normalsData appendBytes:&vertex length:sizeof(Vector3D)];
}

- (void)addTextureCoordinate:(Vector2D)coord {
	[texCoordsData appendBytes:&coord length:sizeof(Vector2D)];
	isTextured = true;
}

-(int)faceCount{
	return faceCount;
}


- (GLuint)indexesName:(GLenum)usage { // the VBO for the indexes

	if(0 == indexesName) {
		sortedIndexData = (void*)vertexIndexData.bytes;
		faceCount =  vertexIndexData.length / 3;

		glGenBuffers(1, &indexesName);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexesName);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, vertexIndexData.length, 
					 sortedIndexData, usage);
		
		indexCount =  [vertexIndexData length] / sizeof(GLshort);

		//[vertexIndexData release];
		[normalsIndexData release];
		[textureCoordinatesIndexData release];
	}
	return indexesName;
}

- (GLuint)vboName:(GLenum)usage {  //VBO for the works

	if(0 == vboName) {
		GLuint vboSize = vertexData.length+normalsData.length+texCoordsData.length;
		
		GLfloat uSize = 1, vSize = 1;
		GLfloat	uOffset = 0, vOffset = 0;
		//TODO: Check Material.Texture to see if it's located in an Atlas
		BOOL isAtlas = false;
		
		if(isTextured){
			WaveFrontOBJMaterial *m = self.material;
			WaveFrontOBJTexture *texture = [m textureForKey:@"default"];
			isAtlas = [texture isAtlas];
	
			if(isAtlas){
				uSize = texture.uSize;
				vSize = texture.vSize;
				uOffset = texture.uOffset;
				vOffset = texture.vOffset;
			}
		}
		//Alloc a new buffer for the vboData.
		vboData = (char *)malloc(vboSize);
		uint vIndex = 0, nIndex = 0, tIndex = 0;
		Vector3D n;		//Normal
		Vector3D v;		//Vertex
		Vector2D t;		//Texture
		
		int vLen = sizeof(Vector3D);
		
		//Check for texture data... If none, set size of UV to zero.
		int tLen = 0;
		if(isTextured)tLen = sizeof(Vector2D);
		
		//Copy the data to our new buffer
		for(uint i=0; i<vboSize; i+=(vLen + vLen + tLen))
		{
			NSRange vRange = {vIndex, vLen };
			NSRange nRange = {nIndex, vLen };
			
			vIndex += vLen;
			nIndex += vLen;
			
			[vertexData getBytes:&v range:vRange];
			[normalsData getBytes:&n range:nRange];
			
						
			memcpy((vboData+i), &v, vLen);
			memcpy((vboData+i+vLen), &n, vLen);
			
			if(isTextured){
				//TODO: If we're using an atlassed texture, modify the UV values here.
				
				NSRange tRange = {tIndex, tLen };
				tIndex += tLen;
				[texCoordsData getBytes:&t range:tRange];
				
				if(isAtlas){
					t.x = t.x*uSize + uOffset; 
					t.y = t.y*vSize + vOffset;
				}
				
				memcpy((vboData+i+2*vLen), &t, tLen); 
			}	
		}
		
		
		glGenBuffers(1, &vboName);
		glBindBuffer(GL_ARRAY_BUFFER, vboName);
		glBufferData(GL_ARRAY_BUFFER, vboSize, vboData, usage);
		
		vboParam.stride = vLen + tLen + vLen;
		
		glFinish();
		
#if TARGET_IPHONE_SIMULATOR
		//[self cacheVBOData:vboData size:vboSize];
#endif
		free(vboData);
		
		//Release the original data set... It's all in vboData now
		[vertexData release];
		[normalsData release];
		[texCoordsData release];
	}
	return vboName;
}


-(void)cacheVBOData:(char*)data size:(int)size{
	NSLog(@"Caching VBO Data For: %@  Using Texture:%@",self.key, [self.material textureFile]);
	NSString *vrmFolder = @"/Users/Jonathan/Desktop/iPhone Projects/Quarto/Models/vrm2";
	NSString *path = [NSString stringWithFormat:@"%@/%@.vrm",vrmFolder,self.key];

	NSLog(@"Will Write to path %@",path);
	
	NSString *mtlFile = [material textureFile];
	NSData *d = [[NSData alloc] initWithBytes:data length:size];
	NSData *i = vertexIndexData;
	NSNumber *radMax = [NSNumber numberWithFloat:[self radius]];
	
	NSDictionary *md = [NSDictionary dictionaryWithObjectsAndKeys:
						mtlFile,@"textureFile",d,@"vertexData",i,@"indexData",radMax,@"radius",nil];
	
	[md writeToFile:path atomically:TRUE];
}

-(void)loadFromData:(NSData*)d indexData:(NSData*)i{
	glGenBuffers(1, &vboName);
	glBindBuffer(GL_ARRAY_BUFFER, vboName);
	glBufferData(GL_ARRAY_BUFFER, [d length], [d bytes], GL_STATIC_DRAW);
	
	glGenBuffers(1, &indexesName);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexesName);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, [i length], [i bytes], GL_STATIC_DRAW);
	
	faceCount =  i.length / 3;
	indexCount =  [i length] / sizeof(GLshort);
	
	vboParam.stride = sizeof(Vector2D) + sizeof(Vector3D) + sizeof(Vector3D);
}	

- (glVBOParam)vboParam {
	return vboParam;
	
}


-(void)bindTexture
{
	GLuint texId = [self.material textureName];
	vrTexturePool *texturePool = [vrTexturePool sharedvrTexturePool];
	glBindTexture(GL_TEXTURE_2D, texId);
	[texturePool bindCallMade];
}

-(void)dealloc {
	if(vboName)glDeleteBuffers(1, &vboName);
	if(indexesName)glDeleteBuffers(1, &indexesName);
	
	
	[vertexIndexData release];
    //[normalsIndexData release];
    //[textureCoordinatesIndexData release];
    
	//if(!vboData){
		//[vertexData release];
		//[normalsData release];
		//[texCoordsData release];
	//} else {
	//if(vboData)free(vboData);
	//}
	
	[instanceVBOs release];
	[material release];
	[names release];
	
	//free(sortedIndexData);
	[super dealloc];
}


@end
