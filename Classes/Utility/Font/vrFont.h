//
//  vrFont.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/12/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "OpenGLCommon.h"
#import "Texture2D.h"

#define kVRFontMaxLength 48

//This is your ASCII offset... Start your maps at the "space" and include everything
//up to ASCII 128...  This class will kak if you leave out any of the characters...
#define kFMCharStart	 32 


/****
If you don't have "OpenGLCommon.h" - it simply defines a few data structures... 
The important ones are these two:
 
typedef struct {float x; float y; float z;}Vector3D;
typedef struct {float x; float y;}Vector2D;
****/

typedef struct {
	int			character;
	int			a;
	int			c;
	int			width;
	int			height;
	Vector2D	topLeft;
	Vector2D    bottomRight;
	Vector2D	uvs[6];
}vrFontGlyph;

@interface vrFont : NSObject {
	vrFontGlyph		*_glyphs;
	int				_glyphCount;
	Texture2D		*_fontTexture;
	
	Vector2D		_uvs[kVRFontMaxLength*6];
	Vector3D		_verts[kVRFontMaxLength*6];
}


/*!
    @method		(id)initWithFontDef:(NSString *)fName withTexture:(NSString *)tName;
    @abstract   Initialize the font engine with a definition file & texture
    @discussion Inputs: Simple file names.  Bundle will be searched
*/
-(id)initWithFontDef:(NSString *)fName withTexture:(NSString *)tName;

/*!
    @method     (void)loadFontTextureFromFile:(NSString *)fName;
    @abstract   Loads the font texture map from the given filename
    @discussion Inputs: Simple file name.  
*/
-(void)loadFontTextureFromFile:(NSString *)fName;

/*!
    @method     -(void)parseFontDef:(NSString *)fName
    @abstract   Parses a .ini font definition or loads a pre-parsed .fnt file
    @discussion Parser will automatically determine the file type and load the glyph data.
*/
-(void)parseFontDef:(NSString *)fName;

/*!
 @method     -(void)generateUVData:(vrFontGlyph*)g
 @abstract   Generates UV data inside a vrFontGlyph structure
 @discussion Methods must be supplied a fully populated Glyph.  UV's are generated from supplied top-left, bottom-right data.
*/
-(void)generateUVData:(vrFontGlyph*)g;

/*!
 @method     -(void)printGlyphData:(vrFontGlyph*)g
 @abstract   Debug routine for outputting glyph data
 @discussion (none)
*/
-(void)printGlyphData:(vrFontGlyph*)g;

-(void)renderString:(NSString *)string inRect:(CGRect)r;
-(void)renderString:(NSString *)string inRect:(CGRect)r centered:(bool)centered;


@end
