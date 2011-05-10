//
//  vrFont.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/12/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrFont.h"
#import "vrConstants.h"

@implementation vrFont


-(id)initWithFontDef:(NSString *)fName withTexture:(NSString *)tName
{
	self = [super init];
	if(self){
		[self parseFontDef:fName];
		[self loadFontTextureFromFile:tName];
	}
	return self;
}

-(void)dealloc
{
	if(_glyphs)free(_glyphs);
	[_fontTexture release];
	[super dealloc];
}

-(void)loadFontTextureFromFile:(NSString *)fName
{
	/***
	 Use your own texture loading code here if you wish...  Texture 2D
	 is available in the "Crash Landing" example or in the Oolong engine.
	 ***/
	
	NSString *path = [[NSBundle mainBundle] pathForResource:fName ofType:nil];
	if(!path){
		NSLog(@"[vrFONT ERROR] Could not find font texture file %@",fName);
		return;
	}
	
	[_fontTexture release];
	_fontTexture = [[Texture2D alloc] initWithImagePath:path];
	return;
}


-(void)parseFontDef:(NSString *)fName
{
	
	/**********
	 Check if the font def is a .fnt file (as exported by the parser below).  If
	 so, simply dump the contents into a structure of glyphs.
	 ********/
	
	NSArray *fNameParts = [fName componentsSeparatedByString:@"."];
	if([[fNameParts lastObject] isEqualToString:@"fnt"])
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:fName ofType:nil];
		if(path){
			NSData *fd = [[NSData alloc] initWithContentsOfFile:path];
			if(fd){
				LOG(NSLog(@"Loading Font Data from fnt file..."));
				_glyphs = malloc([fd length]);
				memcpy(_glyphs, [fd bytes], [fd length]);
				_glyphCount = [fd length]/sizeof(vrFontGlyph);
				[fd release];
				return;
			}else{
				NSLog(@"[vrFONT ERROR] could allocate Data from %@",fName);
			}
			NSLog(@"[vrFONT ERROR] could not find %@",fName);
			return;
		}
	}
	
	//bool savefnt = true;
	/***********
	 Assume the data is a text file and parse it on the fly
	 ***********/
	
	NSString *path = [[NSBundle mainBundle] pathForResource:fName ofType:nil];
	if(!path){
		NSLog(@"ERROR: Font Def Does Not Exist (%@)",fName);
		return;
	}
	
	LOG(NSLog(@"Parsing font def file..."));
	
	NSString *fontDef = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
	NSArray *fontDefLines = [fontDef componentsSeparatedByString:@"\n"];
	
	int glyphCount=0;
	
	for(NSString *line in fontDefLines){
		if([line hasPrefix:@"NumFont"]){
			NSArray *parts = [line componentsSeparatedByString:@"="];
			NSString *gc = [parts lastObject];
			glyphCount = [gc intValue];
			break;
		}
	}
	
	if(!glyphCount){
		NSLog(@"Error: Glyph Count is Zero Aborting");
		return;
	}
	
	/********
	 The following will parse a .ini file exported by Nitrogen Font Studio...
	 This is a bit slow so you'll probably want to uncomment the code that saves this
	 to disk.  Run it on the simulator, copy the .fnt file to your project, then use
	 that instead.
	 ******/
	 
	_glyphs		= (vrFontGlyph*)malloc(glyphCount*sizeof(vrFontGlyph));
	_glyphCount = glyphCount;
	
	for(int glyphIndex=0; glyphIndex<=glyphCount; glyphIndex++)
	{
		for(NSString *line in fontDefLines)
		{
			int space=2;
			if(glyphIndex<10)space=1;
			
			vrFontGlyph *g = _glyphs+glyphIndex;
			
			if([line hasPrefix:[NSString stringWithFormat:@"%d",glyphIndex]])
			{
				NSString *data = [line substringFromIndex:space];
				NSArray *parts = [data componentsSeparatedByString:@"="];
				
				NSString *arg = [parts objectAtIndex:0];
				NSString *val = [parts objectAtIndex:1];
				
				if([arg isEqualToString:@"Char"]){
					g->character = [val intValue];
				}
				if([arg isEqualToString:@"A"]){
					g->a = [val intValue];
				}
				else if([arg isEqualToString:@"C"]){
					g->c = [val intValue];
				}
				else if([arg isEqualToString:@"Wid"]){
					g->width = [val intValue];
				}
				else if([arg isEqualToString:@"Hgt"]){
					g->height = [val intValue];
				}
				else if([arg isEqualToString:@"X1"]){
					g->topLeft.x = [val floatValue];
				}
				else if([arg isEqualToString:@"Y1"]){
					g->topLeft.y = [val floatValue];
				}	
				else if([arg isEqualToString:@"X2"]){
					g->bottomRight.x = [val floatValue];
				}	
				else if([arg isEqualToString:@"Y2"]){
					g->bottomRight.y = [val floatValue];
				}	
			}
		}
		//[self printGlyphData:_glyphs+glyphIndex];
		[self generateUVData:_glyphs+glyphIndex];
	}
	
	/*****
	 The following will write the font glyph data to disk.  You can then
	 use this to quickly load the glyph data later.  Parsing the .ini file
	 on the iPhone is far too slow.
	 ******/

	if(TARGET_IPHONE_SIMULATOR){
		NSMutableData *fontData = [[NSMutableData alloc] init];
		[fontData appendBytes:_glyphs length:glyphCount*sizeof(vrFontGlyph)];
		[fontData writeToFile:@"FontData.fnt" atomically:false];
		[fontData release];
	}
}

-(void)generateUVData:(vrFontGlyph*)g
{
	/****
	These UVs assume a "Back-button to left" orientation.  Play with the order
	to rotate to suit your co-ordinate system.
	****/ 
	
	Vector2D *uvs = g->uvs;
	
	Vector2D uvTemp		= g->topLeft;
	g->topLeft.y		= g->bottomRight.y;
	g->bottomRight.y	= uvTemp.y;
	
	uvs[0].x = g->topLeft.x;
	uvs[0].y = g->topLeft.y;
	
	uvs[1].x = g->topLeft.x;
	uvs[1].y = g->bottomRight.y;
	
	uvs[2].x = g->bottomRight.x;
	uvs[2].y = g->topLeft.y;
	
	uvs[3]	 = uvs[1];
	
	uvs[4].x = g->bottomRight.x;
	uvs[4].y = g->bottomRight.y;
	
	uvs[5]   = uvs[2];	
}

-(void)renderString:(NSString *)string inRect:(CGRect)r
{
	[self renderString:string inRect:r centered:false];
}

-(void)renderString:(NSString *)string inRect:(CGRect)r centered:(bool)centered
{
	/****
	 The orientation of the rect you're drawing in is implementation dependent.
	 Play with things if text is showing up sideways or upside down.
	 
	 Note: Your string will not be contained horizontally in the CGRect - it will
		   either start at the origin, or be centered in it, but it will draw
	       outside the horizontal bounds if need be.  The height of the rect
		   will determine the point size of the font.
	 ****/
	
	int length = [string length];
	Vector3D verts[6];
	{
		for(int i=0;i<6;i++)verts[i].z=-1.2;
		
		verts[0].x=r.origin.x+r.size.width;
		verts[1].x=r.origin.x;
		verts[2].x=verts[0].x;
	
		verts[3].x=verts[1].x;
		verts[4].x=verts[1].x;
		verts[5].x=verts[0].x;
	}
	
	/*****
	 If we want to center the text, we need to precaluclate how long the finished
	 string will be... Slow - but effective
	 
	 If not centered, just set the starting point to the CGRect origin.
	 *****/
	
	float x=0;
	if(centered){
		for(int k=0;k<length;k++){
			unichar c;
			c = [string characterAtIndex:k];
			unsigned int index = c-kFMCharStart;
			if(index>_glyphCount)index=0;
			vrFontGlyph g = _glyphs[index];
			float wFactor = r.size.width/(float)g.height;
			x+=g.a*wFactor;
			x+=(g.c)*wFactor;
		}
		float extraSpace = r.size.height-x;
		x=extraSpace/2+r.origin.y;
	}
	else{
		x = r.origin.y;
	}	
		
	for(int k=0;k<length;k++){
		unichar c;
		c = [string characterAtIndex:k];
		unsigned int index = c-kFMCharStart;
		
		if(index>_glyphCount)index=0;
		
		vrFontGlyph g = _glyphs[index];
		
		/****
		 To ensure proper scaling we define wFactor as "desired height/actual height".  This ensures our horizontal spacing
		 is scaled by the same factor as the height. 
		 
		 For this to work - our font should be exported in a "grid" format so that all
		 characters have the same bounding dimensions.
		 ****/
		
		float wFactor = r.size.width/(float)g.height;
		
		//Move forward by "A" pixels (scaled appropriately)
		x += g.a*wFactor;
		{
			float f = (float)g.width*wFactor;
			verts[0].y=x;
			verts[1].y=x;
			verts[2].y=x+f;
			
			verts[3].y=x;
			verts[4].y=x+f;
			verts[5].y=x+f;
		}		
		//Done the character, move forward by "C" pixels (Scaled appropriately)
		x += (g.c)*wFactor;
		
		//Copy the UV and vertex data to _verts and _uvs
		
		memcpy(_verts+k*6,verts,6*sizeof(Vector3D));
		memcpy(_uvs+k*6,&(g.uvs),6*sizeof(Vector2D));
	}
	
	
	//Render
	glBindTexture(GL_TEXTURE_2D, _fontTexture.name);
	glVertexPointer(3, GL_FLOAT, 0, _verts);
	glTexCoordPointer(2, GL_FLOAT, 0, _uvs);
	glDrawArrays(GL_TRIANGLES, 0, length*6);
	
}

-(void)printGlyphData:(vrFontGlyph*)g
{
	printf("*******Glyph Data Dump************\n");
	printf("[Glyph Data]  Character: %d (%c)\n",g->character,(char)(g->character));
	printf("[Glyph Data]  A--------: %d\n",g->a);
	printf("[Glyph Data]  C--------: %d\n",g->c);
	printf("[Glyph Data]  Width----: %d\n",g->width);
	printf("[Glyph Data]  Height---: %d\n",g->height);
	printf("[Glyph Data]  TopLeft--: (%f,%f)\n",g->topLeft.x,g->topLeft.y);
	printf("[Glyph Data]  BtmRight-: (%f,%f)\n",g->bottomRight.x,g->bottomRight.y);
}



@end
