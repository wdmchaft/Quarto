//
//  WaveFrontOBJScene.m
//  OpenGLBricks
//
//  Created by Bill Dudney on 12/18/08.
//  Copyright 2008 Gala Factory Software LLC. All rights reserved.
//

#import "WaveFrontOBJScene.h"

void ReleaseVector3D(CFAllocatorRef allocator, const void *value) {
	CFAllocatorDeallocate(allocator, (void *)value);
}

const void * RetainVector3D(CFAllocatorRef allocator, const void *value) {
	Vector3D *ptr = (Vector3D *)CFAllocatorAllocate(allocator, sizeof(Vector3D), 0);
	ptr->x = ((Vector3D *)value)->x;
	ptr->y = ((Vector3D *)value)->y;
	ptr->z = ((Vector3D *)value)->z;
	return ptr;
}

CFStringRef Vector3DDescription (const void *value) {
	Vector3D *p = (Vector3D *)value;
	return (CFStringRef)[[NSString alloc] 
						 initWithFormat:@"{%5.5f, %5.5f, %5.5f}", 
						 p->x, p->y, p->z];
}


void ReleaseTextureCoord(CFAllocatorRef allocator, const void *value) {
	CFAllocatorDeallocate(allocator, (void *)value);
}

const void * RetainTextureCoord(CFAllocatorRef allocator, const void *value) {
    Vector2D  *ptr = (Vector2D*)CFAllocatorAllocate(allocator, sizeof(Vector2D), 0);
	ptr->x = ((Vector2D *)value)->x;
	ptr->y = ((Vector2D *)value)->y;
	return ptr;
}

CFStringRef TextureCoordDescription (const void *value) {
	NSString *description = nil;
	Vector2D *c = (Vector2D *)value;
	description = [[NSString alloc] initWithFormat:@"{%5.5f, %5.5f}", c->x, c->y];
	return (CFStringRef)description;
}


#define kNoLineType 0
#define kFaceLineType 5
#define kVertexLineType 10
#define kVertexNormalLineType 15
#define kTextureCoordLineType 20
#define kSmoothingGroupLineType 25
#define kGroupNameLineType 30
#define kUseMaterialLineType 35
#define kMaterialLibraryLineType 40
#define kCommentLineType 45

@implementation WaveFrontOBJScene

@synthesize materials;
@synthesize groups;
@synthesize primaryMesh = _primaryMesh;
@synthesize	key;

- (NSUInteger)_lineType:(NSString *)line {
	NSUInteger type = kNoLineType;
	NSRange typeRange = [line rangeOfString:@"v " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
	if(typeRange.location == 0) {
		type = kVertexLineType;
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"vn " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kVertexNormalLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"vt " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kTextureCoordLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"f " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kFaceLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"s " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kSmoothingGroupLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"g " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kGroupNameLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"usemtl " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kUseMaterialLineType;
		}
	}
	
	if(type == kNoLineType) {
		typeRange = [line rangeOfString:@"mtllib " options:NSLiteralSearch range:NSMakeRange(0, [line length])];
		if(typeRange.location == 0) {
			type = kMaterialLibraryLineType;
		}
	}
	
	// a comment
	typeRange = [line rangeOfString:@"#" options:NSLiteralSearch range:NSMakeRange(0, 1)];
	if(typeRange.location == 0) {
		type = kCommentLineType;
	}
	
	return type;
}

- (Vector3D)_parseVector3DLine:(NSString *)line {
	NSScanner *scan = [NSScanner scannerWithString:line];
	[scan setScanLocation:2]; // skip to the #'s
	Vector3D vector;
	BOOL finished = NO;
	NSUInteger count = 0;
	while(!finished) {
		GLfloat value = 0.0;
		if([scan scanFloat:&value]) {
			if(count == 0) vector.x = value;
			if(count == 1) vector.y = value;
			if(count == 2) vector.z = value;
			count++;
		} else {
			finished = YES;
		}
		if(count == 3) {
			finished = YES; // ignore the w in 'v' records
		}
	}
	return vector;
}

- (void)_parseVertexLine:(NSString *)line forGroup:(WaveFrontOBJGroup *)group {
	[group addVertex:[self _parseVector3DLine:line]];
}

- (void)_parseNormalLine:(NSString *)line forGroup:(WaveFrontOBJGroup *)group {
	[group addNormal:[self _parseVector3DLine:line]];
}

// always returns a 2D texture co-ordinate
- (Vector2D)_parseTextureLine:(NSString *)line {
	NSScanner *scan = [NSScanner scannerWithString:line];
	[scan setScanLocation:2]; // skip to the #'s
	Vector2D coord;; // make one big enough to hold everything
	BOOL finished = NO;
	NSUInteger count = 0;
	while(!finished) {
		GLfloat value = 0.0;
		if([scan scanFloat:&value]) {
			if(count == 0) coord.x = value;
			if(count == 1) coord.y = value;
			//if(count == 2) coord.w = value;
			count++;
		} else {
			finished = YES;
		}
	}
	//coord.count = count;
	return coord;
}

- (void)_parseTextureLine:(NSString *)line forGroup:(WaveFrontOBJGroup *)group {
	NSScanner *scan = [NSScanner scannerWithString:line];
	[scan setScanLocation:2]; // skip to the #'s
	Vector2D coord;  //Assume this is a 2D texture... Fragile - but realistic.
	BOOL finished = NO;
	NSUInteger count = 0;
	while(!finished) {
		GLfloat value = 0.0;
		if([scan scanFloat:&value]) {
			if(count == 0) coord.x = value;
			if(count == 1) coord.y = value;
			count++;
		} else {
			finished = YES;
		}
	}
	[group addTextureCoordinate:coord];
}

- (NSString *)_nextLineFromData:(NSString *)data withRange:(NSRange *)range {
	NSRange lineRange;
	NSUInteger start = 0;
	NSUInteger end = 0;
	NSUInteger contentEnd = 0;
	[data getLineStart:&start end:&end contentsEnd:&contentEnd forRange:*range];
	lineRange.location = start;
	lineRange.length = end - start;
	range->location = end + 1;
	return [data substringWithRange:lineRange];
}

- (void)_loadData:(NSString *)data {  
	// pull all the data out of the file which was sucked into the string called
	// data
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	WaveFrontOBJGroup *group = [[WaveFrontOBJGroup alloc] init];
	
	
	CFArrayCallBacks callbacks	= {0, NULL, NULL, NULL, NULL};
	callbacks.release			= ReleaseVector3D;
	callbacks.retain			= RetainVector3D;
	callbacks.copyDescription	= Vector3DDescription;
	CFMutableArrayRef vertexes	= CFArrayCreateMutable(NULL, 0, &callbacks);
	CFMutableArrayRef normals	= CFArrayCreateMutable(NULL, 0, &callbacks);
	
	callbacks.release			= ReleaseTextureCoord;
	callbacks.retain			= RetainTextureCoord;
	callbacks.copyDescription	= TextureCoordDescription;
	CFMutableArrayRef texCoords = CFArrayCreateMutable(NULL, 0, &callbacks);
	
	// if there are multiple objects in the file they have their vertides 
	// intersperced with the rest of the info we do an offset to capture that
	// and when the vertices are copied into the group the index is rewriten
	// with that offset in mind
	//
	// but when there is only one object in the file, all the vertexes are at
	// the top of the file, then the groups are at the bottom and there is no
	// other vertexes
	
	NSUInteger startVertexIndexCount = 0;
	NSUInteger startNormalIndexCount = 0;
	NSUInteger startTexCoordIndexCount = 0;
	NSUInteger vertexIndexCount = 0;
	NSUInteger normalIndexCount = 0;
	NSUInteger texCoordIndexCount = 0;
	
	BOOL scannedAFaceLine = NO;
	NSRange range = NSMakeRange(0, 0);
	
	while(range.location != NSNotFound && range.location < [data length]) {
		NSString *line = [self _nextLineFromData:data withRange:&range];
		NSUInteger lineType = [self _lineType:line];
		switch (lineType) {
			case kVertexLineType: {
				if(YES == scannedAFaceLine) {
					[groups addObject:group];
					[group release];
					group = [[WaveFrontOBJGroup alloc] init];
					scannedAFaceLine = NO;
					startVertexIndexCount = vertexIndexCount;
					startNormalIndexCount = normalIndexCount;
					startTexCoordIndexCount = texCoordIndexCount;
				}
				// found a vertex
				Vector3D vertex = [self _parseVector3DLine:line];
				CFArrayAppendValue(vertexes, &vertex);
				vertexIndexCount++;
				break;
			}
			case kVertexNormalLineType: {
				// found a normal
				Vector3D normal = [self _parseVector3DLine:line];
				CFArrayAppendValue(normals, &normal);
				normalIndexCount++;
				break;
			}
			case kTextureCoordLineType: {
				// found a texture coordinate
				Vector2D texCoord = [self _parseTextureLine:line];
				CFArrayAppendValue(texCoords, &texCoord);
				texCoordIndexCount++;
				break;
			}
			case kGroupNameLineType: {
				NSScanner *scan = [NSScanner scannerWithString:line];
				[scan setScanLocation:2];
				BOOL finished = NO;
				NSMutableArray *groupNames = [NSMutableArray array];
				NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
				while(!finished) {
					NSString *groupName = nil;
					if([scan scanUpToCharactersFromSet:set intoString:&groupName]) {
						if(nil == groupName) {
							NSLog(@"adding nil");
						}
						[groupNames addObject:groupName];
					} else {
						finished = YES;
					}
				}
				if(YES == scannedAFaceLine) {
					[groups addObject:group];
					[group release];
					group = [[WaveFrontOBJGroup alloc] init];
					scannedAFaceLine = NO;
				}        
				group.names = groupNames;
				break;
			}
			case kSmoothingGroupLineType: {
				// found a smoothing group, should be only one int after the s
				// that group is then used as a name for the faces
				NSScanner *scan = [NSScanner scannerWithString:line];
				[scan setScanLocation:2];
				BOOL smoothingGroup = NO;
				if(![scan scanInt:(int*)&smoothingGroup]) {
					NSRange range = NSMakeRange(2, [line length] - 3);
					NSString *onOff = [line substringWithRange:range];
					if([onOff isEqualToString:@"on"]) {
						smoothingGroup = YES;
					} else {
						smoothingGroup = NO;
					}
				}
				group.smoothing = smoothingGroup;
				break;
			}
			case kFaceLineType: {
				// next vertex will cause a new group to be created
				scannedAFaceLine = YES;
				// found a face
				// should I be using smoothingGroup to capture different shapes?
				NSScanner *scan = [NSScanner scannerWithString:line];
				[scan setScanLocation:2];
				GLint vertexIndex = 0;
				GLint textureIndex = 0;
				GLint normalIndex = 0;
				BOOL finished = NO;
				while(!finished) {
					if([scan scanInt:&vertexIndex]) {
						Vector3D *vertex = (Vector3D*)CFArrayGetValueAtIndex(vertexes, vertexIndex - 1);
						[group addVertex:*vertex atIndex:vertexIndex - (startVertexIndexCount + 1)];
					}
					// add one so we can skip the line end
					if([scan scanLocation] + 1 >= line.length) {
						finished = YES;
					} else {
						unichar slash = [line characterAtIndex:[scan scanLocation]];
						if('/' == slash) {
							// move beyond the '/' and look for an int
							[scan setScanLocation:[scan scanLocation] + 1];
							if([scan scanInt:&textureIndex]) {
								Vector2D *textCoord = (Vector2D*)CFArrayGetValueAtIndex(texCoords, textureIndex - 1);  
								[group addTexCoord:*textCoord atIndex:textureIndex - (startTexCoordIndexCount + 1)];
							}
						}
						slash = [line characterAtIndex:[scan scanLocation]];
						if('/' == slash) {
							// move beyond the '/' and look for an int
							[scan setScanLocation:[scan scanLocation] + 1];
							if([scan scanInt:&normalIndex]) {
								Vector3D *normal = (Vector3D*)CFArrayGetValueAtIndex(normals, normalIndex - 1);
								[group addNormal:*normal atIndex:normalIndex - (startNormalIndexCount + 1)];
							}
						}
					}
				}
				break;
			}
			case kUseMaterialLineType: {
				NSRange range = NSMakeRange(7, [line length] - 8);
				group.material = [materials objectForKey:[line substringWithRange:range]];
				break;
			}
			case kMaterialLibraryLineType: {
				NSScanner *scan = [NSScanner scannerWithString:line];
				[scan setScanLocation:7];
				BOOL finished = NO;
				NSMutableArray *mtllibFileNames = [NSMutableArray array];
				NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
				while(!finished) {
					NSString *mtllibFileName = nil;
					if([scan scanUpToCharactersFromSet:set intoString:&mtllibFileName]) {
						[mtllibFileNames addObject:mtllibFileName];
					} else {
						finished = YES;
					}
				}
				NSMutableArray *libraries = [NSMutableArray array];
				for(NSString *materialLibraryFileName in mtllibFileNames) {
					NSArray *mtls = [WaveFrontOBJMaterial materialsFromLibraryFile:materialLibraryFileName];
					//for(WaveFrontOBJMaterial *m in mtls){
						//m.fileName = materialLibraryFileName;
					//}
					[libraries addObjectsFromArray:mtls];
				}
				self.materials = [NSDictionary dictionaryWithObjects:libraries 
															 forKeys:[libraries valueForKeyPath:@"name"]];
				break;
			}
			default:
				break;
		}
	}
	[groups addObject:group];
	group.key = self.key;
	self.primaryMesh = [groups objectAtIndex:0];
	//Load the texture and/or determine what atlas the texture is in
	//Clean Up
	[group release];
	//[materials release];
	CFRelease(vertexes); 
	CFRelease(normals);
	CFRelease(texCoords);
	[pool release];
}

-(void)loadFromDictionary:(NSDictionary *)d
{
	NSLog(@"Loading Model %@ From Cached Data....",self.key);
	
	NSData *vertexData = [d objectForKey:@"vertexData"];
	NSData *indexData = [d objectForKey:@"indexData"];
	NSString *mtllibFileName = [d objectForKey:@"materialFile"]; 
	
	NSLog(@"   Material File:%@",mtllibFileName);
	NSLog(@"   Data Length:%d",[vertexData length]);
	
	NSArray *mtls = [WaveFrontOBJMaterial materialsFromLibraryFile:mtllibFileName];
	
	//self.materials = [NSDictionary dictionaryWithObjects:mtls forKeys:[mtls valueForKeyPath:@"name"]];
	
	NSLog(@"   Found %d Materials",[mtls count]);
	
	WaveFrontOBJGroup *group = [[WaveFrontOBJGroup alloc] init];
	[groups addObject:group];
	group.material = [mtls objectAtIndex:0];
	self.primaryMesh = group;
	
	[group loadFromData:vertexData indexData:indexData];
}


-(bool)enableMaterial{
	return false;
}

- (id)initWithPath:(NSString *)objFilePath key:(NSString*)mkey {
	return [self initWithURL:[NSURL fileURLWithPath:objFilePath] key:mkey];
}

- (id)initWithURL:(NSURL*)objFileURL key:(NSString*)mkey{
	self = [super init];
	if(nil != self) {
		self.key = mkey;
		objURL = [objFileURL retain];
		groups = [[NSMutableArray alloc] init];

		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		NSDictionary *d = [ud objectForKey:self.key];
		if(d){
			[self loadFromDictionary:d];
		}else{		
			[self _loadData:[NSString stringWithContentsOfURL:objURL encoding:NSASCIIStringEncoding error:NULL]];
		}
		for(WaveFrontOBJGroup *group in [self groups])[group vboName:GL_STATIC_DRAW];
	}
	return self;
}



-(void)drawSelf {
		for(WaveFrontOBJGroup *group in [self groups]) {
		[self preConfigureGroup:group];
		[self drawGroup:group];
		[self cleanUp];
	}

}

-(void)drawGroup:(WaveFrontOBJGroup *)group
{
	glDrawElements(GL_TRIANGLES, group.indexCount, GL_UNSIGNED_SHORT, NULL);		
}


-(void)preConfigureGroup:(WaveFrontOBJGroup *)group
{
	GLuint vboName = 0;
	
	if(!vboName){
		vboName = [group vboName:GL_STATIC_DRAW];
	}
	
	glVBOParam vboParam = [group vboParam];
	GLuint stride = vboParam.stride;
	
	glBindBuffer(GL_ARRAY_BUFFER, vboName);
	glVertexPointer(3, GL_FLOAT, stride, 0);
	glNormalPointer(GL_FLOAT, stride, (void*)sizeof(Vector3D));
	
	if([self enableMaterial]){
		ColorRGBA color = group.material.ambientColor;
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (GLfloat *)&color);
		color = group.material.diffuseColor;
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, (GLfloat *)&color);
		color = group.material.specularColor;
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (GLfloat *)&color);
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, group.material.shine);
	}
	
	if(group.isTextured) {
		glTexCoordPointer(2, GL_FLOAT, stride, (void*)(2*sizeof(Vector3D)));
		GLuint texId = [[group material] textureName];
		glBindTexture(GL_TEXTURE_2D, texId);
	}
	else {
		//glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		_textureDisabled = true;
	}

	GLuint indexesName = [group indexesName:GL_STATIC_DRAW];
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexesName);
	
}

-(void)cleanUp{
	if(_textureDisabled){
		//glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		_textureDisabled = false;
	}
}


- (void)dealloc {
	[_primaryMesh release];
	[objURL release];
	[materials release];
	[groups release];
	[super dealloc];
}

@end
