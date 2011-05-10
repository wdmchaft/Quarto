//
//  vrControl.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/03/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrTypeDefs.h"
#import "OpenGLCommon.h"
#import "glUtility.h"
#import "vrUIControl.h"
#import "Texture2D.h"
#import "glTextManager.h"
#import "vrTexturePool.h"

#define kControlTextDropShadowColour .2,.2,.2,.7
#define kControlTextColour 1,1,1,1

typedef struct {
	CGRect		rect;
	Texture2D	*texture;
}vrControlDrawData;

@interface vrControl : vrUIControl {
	Texture2D	*_upTexture;
	Texture2D	*_downTexture;
	Texture2D	*_overlayTexture;
	
	NSString	*_upTextureKey;
	NSString	*_downTextureKey;
	NSString	*_overlayTextureKey;
	
	glTextManager *_tM;
	NSString	*_label;
	float		_labelUpScale;
	float		_labelDownScale;
	float		_overlayScale;
	
	Color3D		_labelColor;
	Vector3D	_downTranslate;
	Vector3D	_upTranslate;
	
	/****************************************************/
	/* Index and Key Properties can be set to allow
	/* us to glean information about the button upon
	/* callbacks without resorting to a slow compare search
	/****************************************************/
	int			_index;
	
	CGRect labelUpRect, labelDownRect, upRect, downRect;
	CGRect _overlayRect;
	
	bool		_drawOverlayTexture;
}

@property int index;

@property (nonatomic, retain) NSString *upTextureKey;
@property (nonatomic, retain) NSString *downTextureKey;
@property (nonatomic, retain) NSString *overlayTextureKey;

@property (nonatomic) bool drawOverlayTexture;

@property (nonatomic) float labelDownScale;
@property (nonatomic) float overlayScale;

@property (nonatomic, retain) NSString *label;

-(id)initWithProperties:(NSDictionary *)properties;

-(void)setLabelScale:(float)up_scale down:(float)down_scale;
-(void)setLabelColor:(Color3D)color;
-(void)setRects;
-(void)setRects:(ControlRect)cR;
-(void)setCGRect:(CGRect)rect;

//Returns a CGRect and a Texure2D pointer for batch drawing...
-(vrControlDrawData)getDrawingData;

-(void)renderBacking;
-(void)renderLabel;

@end
