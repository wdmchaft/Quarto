//
//  vr3DModel.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 15/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vr3DModel.h"
#import "vrConstants.h"


@implementation vr3DModel

- (id)initWithPath:(NSString *)objFilePath modelKey:(NSString *)key
{
	self = [super init];
	if(self)
	{
		NSString *cFile = [[NSBundle mainBundle] pathForResource:key ofType:@"vrm"];
		if(cFile && kUSEVRM){
			LOG(NSLog(@"Loading Model %@ from VRM File",key));
			[self loadFromVRM:key];
			_isVRM = true;
			LOG(NSLog(@"Loaded with texture key: %@",_textureFile));

		}else{
			if(objFilePath){
				LOG(NSLog(@"WARNING: Loading Model %@ from OBJ File",key));
				_isVRM = false;
				_model = [[WaveFrontOBJScene alloc] initWithPath:objFilePath key:key];
				_radius = [[_model primaryMesh] radius];
			}else{
				NSLog(@"ERROR LOADING MODEL: No Data Found (Key: %@)",key);
				[self release];
				return nil;
			}
		}
		_key = [[NSString alloc] initWithString:key];
	}
	return self;
}

- (id)initWithURL:(NSURL*)objFileURL
{
	self = [super init];
	if(self)
	{
		_isVRM = false;
		_model = [[WaveFrontOBJScene alloc] initWithURL:objFileURL];
	}
	return self;
}

-(void)loadFromVRM:(NSString *)key
{
	LOG(NSLog(@"Loading %@ from VRM file",key));
	NSString *cFile = [[NSBundle mainBundle] pathForResource:key ofType:@"vrm"];
	
	NSDictionary *modelData = [[NSDictionary alloc] initWithContentsOfFile:cFile];
	
	
	NSData *d = [modelData objectForKey:@"vertexData"];
	NSData *i = [modelData objectForKey:@"indexData"];
	NSString *tf = [NSString stringWithString:[modelData objectForKey:@"textureFile"]];
	
	_textureFile = [tf retain];
	
	_radius = [[modelData objectForKey:@"radius"] floatValue];
	
	glGenBuffers(1, &_vboName);
	glBindBuffer(GL_ARRAY_BUFFER, _vboName);
	glBufferData(GL_ARRAY_BUFFER, [d length], [d bytes], GL_STATIC_DRAW);
	
	glGenBuffers(1, &_indexesName);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexesName);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, [i length], [i bytes], GL_STATIC_DRAW);
	glFlush();
	
	_faceCount =  i.length / 3;
	_indexCount =  [i length] / sizeof(GLshort);
	_stride = sizeof(Vector2D) + sizeof(Vector3D) + sizeof(Vector3D);
	[modelData release];
}


- (void)drawSelf{
	if(_isVRM){
		[self preLoadMesh:nil];
		[self drawMesh:nil];
		//[self cleanUp];
	}else{
		[_model drawSelf];
	}
}

-(void)preLoadMesh:(vrMesh *)group{
	if(_isVRM){
		glBindBuffer(GL_ARRAY_BUFFER, _vboName);
		glVertexPointer(3, GL_FLOAT, _stride, 0);
		glNormalPointer(GL_FLOAT, _stride, (void*)sizeof(Vector3D));
		glTexCoordPointer(2, GL_FLOAT, _stride, (void*)(2*sizeof(Vector3D)));
		vrTexturePool *texturePool = [vrTexturePool sharedvrTexturePool];
		GLuint texId = [texturePool textureIDForKey:_textureFile];
		glBindTexture(GL_TEXTURE_2D, texId);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexesName);
	}else{
		[_model preConfigureGroup:group];
	}
}

-(void)drawMesh:(vrMesh *)mesh
{
	if(_isVRM){
		glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, NULL);		
	}else{
		[_model drawGroup:mesh];
	}
}

-(void)drawMeshLines:(vrMesh *)mesh
{
	if(_isVRM){
		glDisable(GL_TEXTURE_2D);
		glDrawElements(GL_LINE_STRIP, _indexCount, GL_UNSIGNED_SHORT, NULL);
		glEnable(GL_TEXTURE_2D);
	}else{
		[_model drawGroup:mesh];
	}
}

-(GLfloat)radius
{
	return _radius;
}

-(void)cleanUp{
	if(_isVRM){
		
	}else{
		[_model cleanUp];
	}
}

-(NSString *)modelKey{
	return _key;
}

-(NSArray *)meshes{
	if(!_isVRM){
	   return [_model groups];
	}
	return nil;
}

-(vrMesh *)mesh{
	return [_model primaryMesh];
}

-(int)meshCount{
	return 1;
}

-(int)faceCount
{
	return [[_model primaryMesh] faceCount];
}

-(void)bindTexture
{
	if(_isVRM){
		vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
		GLuint texId = [tp atlasTextureIDForKey:_textureFile];
		glBindTexture(GL_TEXTURE_2D, texId);
	}else{
		[[_model primaryMesh] bindTexture];
	}
}


-(void)dealloc
{
	[_textureFile release];
	[_model release];
	[_key release];
	[super dealloc];
}

@end
