//
//  vrControl.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/03/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrControl.h"
#import "NSString+vectorParse.h"

@implementation vrControl
 
@synthesize index = _index;
@synthesize upTextureKey		= _upTextureKey;
@synthesize downTextureKey		= _downTextureKey;
@synthesize overlayTextureKey	= _overlayTextureKey;
@synthesize drawOverlayTexture	= _drawOverlayTexture;
@synthesize labelDownScale		= _labelDownScale;
@synthesize overlayScale		= _overlayScale;
@synthesize label				= _label;

-(id)initWithProperties:(NSDictionary *)properties{
	self = [super initWithProperties:properties];
	if(self){
		if([properties objectForKey:@"controlRect"]){
			_cR = [NSString controlRectFromCDS:[properties objectForKey:@"controlRect"]];
		}
		
		if([properties objectForKey:@"labelUpScale"]){
			_labelUpScale	= [[properties objectForKey:@"labelUpScale"] floatValue];
		}
		else {
			_labelUpScale = 1;
		}
		if([properties objectForKey:@"labelDownScale"]){
			_labelDownScale= [[properties objectForKey:@"labelDownScale"] floatValue];
		}
		else {
			_labelDownScale = 1;
		}
		if([properties objectForKey:@"overlayScale"]){
			_overlayScale = [[properties objectForKey:@"overlayScale"] floatValue];
		}
		else {
			_overlayScale = 1;
		}
		if([properties objectForKey:@"downDelta"]){
			_downTranslate = [NSString vector3DFromCDS:[properties objectForKey:@"downDelta"]];
		}
		if([properties objectForKey:@"downDeltaX"]){
			_downTranslate.x = [[properties objectForKey:@"downDeltaX"] floatValue];
		}
		else {
			_downTranslate.x = 0;
		}
		if([properties objectForKey:@"downDeltaY"]){
			_downTranslate.y = [[properties objectForKey:@"downDeltaY"] floatValue];
		}
		if([properties objectForKey:@"upDeltaX"]){
			_upTranslate.x = [[properties objectForKey:@"upDeltaX"] floatValue];
		}
		else {
			_upTranslate.x = 0;
		}
		if([properties objectForKey:@"upDeltaY"]){
			_upTranslate.y = [[properties objectForKey:@"upDeltaY"] floatValue];
		}
		else {
			_upTranslate.y = 0;
		}
		if([properties objectForKey:@"soundOnSwipe"]){
			_soundOnSwipe = [[properties objectForKey:@"soundOnSwipe"] boolValue];
		}
		else{
			_soundOnSwipe = false;
		}
		
		
		if([properties objectForKey:@"label"]){
			self.label = [properties objectForKey:@"label"];
		}
		if([properties objectForKey:@"textureKeyInactive"]){
			self.upTextureKey = [properties objectForKey:@"textureKeyInactive"];
		}
		if([properties objectForKey:@"textureKeyActive"]){
			self.downTextureKey = [properties objectForKey:@"textureKeyActive"];
		}
		if([properties objectForKey:@"textureKeyOverlay"]){
			self.overlayTextureKey = [properties objectForKey:@"textureKeyOverlay"];
		}
		if([properties objectForKey:@"upAudioKey"]){
			[self setUpAudioKey:[properties objectForKey:@"upAudioKey"]];
		}
		if([properties objectForKey:@"downAudioKey"]){
			[self setDownAudioKey:[properties objectForKey:@"downAudioKey"]];
		}
		
		if(_upTextureKey)_upTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_upTextureKey];
		if(_downTextureKey)_downTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_downTextureKey];
		if(_overlayTextureKey)_overlayTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_overlayTextureKey];
		
		_labelColor = Color3DMake(0,.8,0,1);
		
		[self setRects];
	}
	return self;
}



-(void)setRects:(ControlRect)cR{
	_cR = cR;
	CGRect bounds = ScaledBounds();;
	_cR.top *= bounds.size.height/480.0f;
	_cR.bottom *= bounds.size.height/480.0f;
	_cR.left *= bounds.size.width/320.0f;
	_cR.right *= bounds.size.width/320.0f;
	[self setCGRect:CGRectFromControlRect(_cR)];	
}

-(void)setCGRect:(CGRect)rect
{
	upRect = rect;
	downRect = upRect;

	//upRect.origin.x += _upTranslate.x;
	//upRect.origin.y += _upTranslate.y;
	
	downRect.origin.x += _downTranslate.x;
	downRect.origin.y += _downTranslate.y;
	
	labelUpRect		= scaleRect(rect,_labelUpScale);
	labelDownRect	= scaleRect(rect,_labelDownScale);

	labelUpRect.origin.x -= labelUpRect.size.width/10 + _upTranslate.x;
	labelUpRect.origin.y -= labelUpRect.size.height/30 + _upTranslate.y;
	
	labelDownRect.origin.x -= labelDownRect.size.width/10;
	labelDownRect.origin.y -= labelDownRect.size.height/30;
	

	labelDownRect.origin.x += _downTranslate.x;
	labelDownRect.origin.y += _downTranslate.y;
	
	_overlayRect = scaleRect(upRect,_overlayScale);
}


-(void)setRects{
	if(_autoScale){
		CGRect bounds = ScaledBounds();
		_cR.top *= bounds.size.height/480.0f;
		_cR.bottom *= bounds.size.height/480.0f;
		_cR.left *= bounds.size.width/320.0f;
		_cR.right *= bounds.size.width/320.0f;
	}
	[self setCGRect:CGRectFromControlRect(_cR)];
}

-(void)setLabelScale:(float)up_scale down:(float)down_scale;
{
	_labelUpScale	= up_scale;
	_labelDownScale	= down_scale;
	
	[self setRects];
}

//Set a vector that will move the label by (x,y) from it's original position
-(void)setLabelDownTranslation:(vrVector2D)p
{
	_downTranslate = Vector3DMake(p.x,p.y,0);
	
	[self setRects];
}


-(void)setLabelColor:(Color3D)color
{
	_labelColor = color;
}

-(void)loadTexturesFromKeys
{
	if(_downTextureKey)_upTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_upTextureKey];
	if(_upTextureKey)_downTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_downTextureKey];
}	
	

-(void)renderBacking
{
	//if(_upTextureKey)_upTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_upTextureKey];
	//else _upTexture = nil;
	
	//if(_downTextureKey)_downTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_downTextureKey];
	//else _downTexture = nil;
	
	//if(_overlayTextureKey)_overlayTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_overlayTextureKey];
	//else _overlayTexture = nil;
	if(_disable)glColor4f(.4,.4,.4,1);
	
	if(_isActive || _forceOn){
		if(_downTexture)[_downTexture drawInRect:downRect depth:-2.0f];
		else if(_upTexture)[_upTexture drawInRect:downRect depth:-2.0f];
		if(_drawOverlayTexture){
			if(_overlayTexture){
				[_overlayTexture drawInRect:_overlayRect depth:-2.0f];
			}
		}
	}
	else{
		if(_upTexture){
			[_upTexture drawInRect:upRect depth:-2.0f];
		}
		if(_drawOverlayTexture){
			if(_overlayTexture){
				[_overlayTexture drawInRect:_overlayRect depth:-2.0f];
			}
		}
	}
	glColor4f(1,1,1,1);
}

-(void)renderLabel
{
	glTextManager *tM = [glTextManager sharedTextManager];
	if(_label && !_disable){
		if(_isActive){
			[tM renderCharacterStringScaled:_label inRect:labelDownRect withShadowOffset:2 centered:true];
		}
		else{
			[tM renderCharacterStringScaled:_label inRect:labelUpRect withShadowOffset:2 centered:true];
		}
		glColor4f(1,1,1,1);
	}
}

-(vrControlDrawData)getDrawingData
{
	vrControlDrawData ret;
	if(_isActive){
		ret.texture = _downTexture;
		ret.rect = downRect;
	}
	else{
		ret.texture = _upTexture;
		ret.rect = upRect;
	}
	return ret;
}

-(void)render
{
	[self loadTexturesFromKeys];
	[self renderBacking];
	[self renderLabel];

}


-(void)dealloc
{

	[_label release];
	[_upTextureKey release];
	[_downTextureKey release];
	[_overlayTextureKey release];
	[super dealloc];
}



@end
