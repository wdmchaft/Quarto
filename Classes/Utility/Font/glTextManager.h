//
//  glTextManager.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 02/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Texture2D.h"
#import "vrTypeDefs.h"
#import "glUtility.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>
#import "vrFont.h"

#define	TEXT_DEPTH		-2.0f
#define DEFAULT_FONT	@"Helvetica-Bold"
#define kMaxStrings		48	

#define kTextScaleFactor 1.0

//#define DEFAULT_FONT_MAP @"NeroP_outline.png"
//#define DEFAULT_FONT_DEF @"NeroP.ini"

#define DEFAULT_FONT_MAP @"TempusLarge_tweaked_512.png"
#define DEFAULT_FONT_DEF @"TempusLarge.ini"
#define GLTM_SHADOW 0

typedef struct {
	CGRect	rect;
	int		shadowOffset;
	bool	centered;
	Color3D	color;
	bool	scale;
}vrFontPerfs;


@interface glTextManager : NSObject {
	NSString			*_fontName;
	Texture2D			*_fontTexture;
	vrFont				*_font;
	BOOL				_renderStateSet;
	uint				_stringCount;
}


//Return a Singleton shared manager using font "DEFAULT_FONT"
+(glTextManager *)sharedTextManager;

-(id)initWithFont:(NSString *)name;

-(void)renderCharacterStringScaled:(NSString *)string withOptions:(vrFontPerfs*)p;
-(void)renderCharacterStringScaled:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset centered:(bool)centered;

-(void)renderCharacterString:(NSString *)string withOptions:(vrFontPerfs*)p;
-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset centered:(bool)centered;
-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset;
-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect centered:(bool)centered;
-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect;

-(void)renderTimeInterval:(NSTimeInterval)interval inRect:(CGRect)rect withPrefix:(NSString*)prefix;

-(void)enableTextRenderStates:(Color3D)color;
-(void)disableTextRenderStates;


@end

