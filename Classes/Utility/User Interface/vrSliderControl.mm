//
//  vrSliderControl.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 18/05/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrSliderControl.h"
#import "NSString+vectorParse.h"


@implementation vrSliderControl

@synthesize reverseDraw = _reverseDraw;


-(id)initWithProperties:(NSDictionary *)properties{
	self = [super initWithProperties:properties];
	if(self){
		if([properties objectForKey:@"rangeMax"]){
			_def.rangeMax = [[properties objectForKey:@"rangeMax"] floatValue];
		}
		else{
			_def.rangeMax = 1;
		}
		if([properties objectForKey:@"rangeMin"]){
			_def.rangeMin = [[properties objectForKey:@"rangeMin"] floatValue];
		}
		else{
			_def.rangeMin = 0;
		}
		if([properties objectForKey:@"zeroWhenReleased"]){
			_zeroWhenReleased = [[properties objectForKey:@"zeroWhenReleased"] boolValue];
		}
		else{
			_zeroWhenReleased = true;
		}
		if([properties objectForKey:@"fullOverlay"]){
			_fullOverlay = [[properties objectForKey:@"fullOverlay"] boolValue];
		}
		else{
			_fullOverlay = false;
		}
		if([properties objectForKey:@"orientation"]){
			bool orientation = [[properties objectForKey:@"orientation"] boolValue];
			if(orientation)_orientation=kHorizontal;
			else _orientation=kVertical;
		}
		else{
			_orientation = kVertical;
		}
		if([properties objectForKey:@"recoilTime"]){
			_def.recoilTime	= [[properties objectForKey:@"recoilTime"] floatValue];
		}
		else{
			_def.recoilTime = 0;
		}
		if([properties objectForKey:@"steps"]){
			_def.steps = [[properties objectForKey:@"steps"] intValue];
		}
		else{
			_def.steps = 0;
		}
		if([properties objectForKey:@"initialValue"]){
			_value = [[properties objectForKey:@"initialValue"] floatValue];
		}
		else {
			_value = 0;
		}
		
		if([properties objectForKey:@"left"]){
			_cR.left = [[properties objectForKey:@"left"] floatValue];
		}
		else {
			_cR.left = 0;
		}
		if([properties objectForKey:@"right"]){
			_cR.right = [[properties objectForKey:@"right"] floatValue];
		}
		else {
			_cR.right = 0;
		}
		if([properties objectForKey:@"top"]){
			_cR.top	= [[properties objectForKey:@"top"] floatValue];
		}
		else {
			_cR.top = 0;
		}
		if([properties objectForKey:@"bottom"]){
			_cR.bottom = [[properties objectForKey:@"bottom"] floatValue];
		}
		else {
			_cR.bottom = 0;
		}
		if([properties objectForKey:@"controlRect"]){
			_cR  = [[properties objectForKey:@"controlRect"] controlRectFromCDS];
		}
		if([properties objectForKey:@"labelUpScale"]){
			_labelUpScale	= [[properties objectForKey:@"upDownScale"] floatValue];
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
		
		if([properties objectForKey:@"label"]){
			[self setLabel:[properties objectForKey:@"label"]];
		}
		if([properties objectForKey:@"textureKeyInactive"]){
			_upTextureKey = [[NSString alloc] initWithString:[properties objectForKey:@"textureKeyInactive"]];
		}
		if([properties objectForKey:@"textureKeyActive"]){
			_downTextureKey = [[NSString alloc] initWithString:[properties objectForKey:@"textureKeyActive"]];
		}
		if([properties objectForKey:@"textureKeyOverlay"]){
			_overlayTextureKey = [[NSString alloc] initWithString:[properties objectForKey:@"textureKeyOverlay"]];
		}
		if([properties objectForKey:@"overlayWidth"]){
			_overlayWidth = [[properties objectForKey:@"overlayWidth"] floatValue];
		}
		if([properties objectForKey:@"overlayHeight"]){
			_overlayHeight = [[properties objectForKey:@"overlayHeight"] floatValue];
		}
		if([properties objectForKey:@"backingSize"]){
			_backingSize = [[properties objectForKey:@"backingSize"] floatValue];
		}else{
			_backingSize = 1;
		}
		if([properties objectForKey:@"instantResponse"]){
			_instantResponse = [[properties objectForKey:@"instantResponse"] boolValue];
		}else{
			_instantResponse = false;
		}
		
		
		CGRect bounds = ScaledBounds();
		_cR.top *= bounds.size.height/480.0f;
		_cR.bottom *= bounds.size.height/480.0f;
		_cR.left *= bounds.size.width/320.0f;
		_cR.right *= bounds.size.width/320.0f;
		
		
		[self setUpAudioKey:[properties objectForKey:@"upAudioKey"]];
		[self setDownAudioKey:[properties objectForKey:@"downAudioKey"]];
		
		if(_upTextureKey)_upTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_upTextureKey];
		if(_downTextureKey)_downTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_downTextureKey];
		if(_overlayTextureKey)_overlayTexture	= [[vrTexturePool sharedvrTexturePool] objectForKey:_overlayTextureKey];
		
		
		
		_value = ( _value - _def.rangeMin) / (_def.rangeMax - _def.rangeMin);
		
		[self setRects];
	}
	return self;
	
	
}

-(void)setRects{
	//upRect	= CGRectFromControlRect(_cR);
	ControlRect t = _cR;
	float width, center;
	
	switch(_orientation)
	{
		case kHorizontal:
			width = fabs(_cR.right - _cR.left)*_backingSize;
			center = (_cR.right + _cR.left)/2;
			t.left	= center-width/2;
			t.right = center+width/2;
			break;
		case kVertical:
			width = fabs(_cR.bottom - _cR.top)*_backingSize;
			center = (_cR.top + _cR.bottom)/2;
			t.top	= center-width/2;
			t.bottom= center+width/2;
			break;
	}
	
	upRect = CGRectFromControlRect(t);
	
	downRect = upRect;
	downRect.origin.x += _downTranslate.x;
	downRect.origin.y += _downTranslate.y;
	
	//TODO: Refine behviour here to handle the geometry of the "down" state
	labelUpRect = scaleRect(CGRectFromControlRect(_cR),_labelUpScale);
	labelDownRect	= scaleRect(CGRectFromControlRect(_cR),_labelDownScale);
	labelDownRect.origin.x += _downTranslate.x;
	labelDownRect.origin.y += _downTranslate.y;
	
	switch(_orientation)
	{
		case kHorizontal:
			if(!_fullOverlay){
				_overlayRect.origin.y = [[UIScreen mainScreen] bounds].size.height-_cR.bottom + (_cR.bottom - _cR.top)*_value - _overlayWidth/2;
				_overlayRect.origin.x = (_cR.right +_cR.left)/2 - _overlayHeight/2;
				_overlayRect.size.width = _overlayWidth;
				_overlayRect.size.height = _overlayHeight;
			}else{
				_overlayRect = upRect;
				_overlayRect.size.height = _overlayRect.size.height*_value;
				_overlayTexture.maxS = _value;
			}
			break;
		case kVertical:
			_overlayRect.origin.y = [[UIScreen mainScreen] bounds].size.height-_cR.bottom + (_cR.bottom - _cR.top)*_value - _overlayWidth/2;
			_overlayRect.origin.x = (_cR.right +_cR.left)/2 - _overlayHeight/2;
			_overlayRect.size.width = _overlayWidth;
			_overlayRect.size.height = _overlayHeight;
			break;
	}
	
}

-(void)zeroWhenReleased:(bool)flag{
	_zeroWhenReleased = flag;
}

-(bool)setSliderOverlayTexture:(Texture2D *)texture{
	_overlayTexture = texture;
	return true;
}


-(void)setOrientation:(vrOrientation)orientation{
	_def.orientation = orientation;
}


-(void)setRangeMin:(float)min max:(float)max steps:(int)steps{
	_def.rangeMin	= min;
	_def.rangeMax	= max;
	_def.steps		= steps;
}

-(void)setRecoilTime:(float)recoilTime{
	_def.recoilTime = recoilTime;
}

-(void)setValue:(float)val{
	if(val > _def.rangeMax){
		NSLog(@"ERROR Setting Slider Value: Below Lower Limit");
		return;
	}
	if(val < _def.rangeMin){
		NSLog(@"ERROR Setting Slider Value: Above Upper Limit");
		return;
	}
	_value = (val - _def.rangeMin) / (_def.rangeMax - _def.rangeMin);
	
	
}

-(float)value 
{
	float r=_def.rangeMin + _value * (_def.rangeMax - _def.rangeMin);
	//printf("AccControl: %f\n",r);
	return r;
}

-(void)setTarget:(id)target
{
	_callbackTarget = target;
}

-(void)setValueChangeCallback:(SEL)selector
{
	_valueChangeCallback = selector;
}

-(void)handleUpTouch:(vrTouchType)type
{
	_isActive = false;
	
}	


-(float)normalizedValue{
	//NSLog(@"NormValue: %f",_value);
	
	float originalVal = _value;
	float tv;
	if(_isActive){
		//TODO: Determine normalized value
		switch(_orientation)
		{
			case kHorizontal:
				tv = (_cR.bottom - touchCurrentLocation.y )/(_cR.bottom-_cR.top);
				break;
			case kVertical:
				tv = (_cR.right - touchCurrentLocation.x)/(_cR.right-_cR.left);
				break;
		}
		
		if(tv >1)tv=1;
		if(tv<0)tv=0;	
		
		if(!_instantResponse){
			if(_value<tv)_value+=.05;
			if(_value>tv)_value-=.05;
		}else{
			_value = tv;
		}
		//NSLog(@"Slider Value: %f",[self value]);
		
	}
	else{
		if(_zeroWhenReleased){
			if(!_instantResponse){
				if(_value>0)_value-=.05;
				if(_value<0)_value=0;
			}
			else {
				_value = 0;
			}
		}	
	}
	
	switch(_orientation)
	{
		case kHorizontal:
			if(!_fullOverlay){
				_overlayRect.origin.y = [[UIScreen mainScreen] bounds].size.height-_cR.bottom + (_cR.bottom - _cR.top)*_value - _overlayWidth/2;
				_overlayRect.origin.x = (_cR.right +_cR.left)/2 - _overlayHeight/2;
				_overlayRect.size.width = _overlayWidth;
				_overlayRect.size.height = _overlayHeight;
			}else{
				_overlayRect = upRect;
				_overlayRect.size.height = _overlayRect.size.height*_value;
				_overlayTexture.maxS = _value;
			}
			break;
		case kVertical:
			if(!_fullOverlay){
				_overlayRect.origin.y = [[UIScreen mainScreen] bounds].size.height - (_cR.bottom + _cR.top)/2 - _overlayHeight/2;
				_overlayRect.origin.x = _cR.right - (_cR.right-_cR.left)*_value - _overlayWidth/2;
				_overlayRect.size.width = _overlayWidth;
				_overlayRect.size.height = _overlayHeight;
			}else{
				_overlayRect = CGRectMake(upRect.size.width+upRect.origin.x,upRect.origin.y, -upRect.size.width*_value, upRect.size.height);
				//_overlayRect.size.width = _overlayRect.size.width*_value;
				_overlayTexture.maxT = _value;
			}
			break;
	}
	
	if(_value != originalVal){
		if(_callbackTarget){
			if([_callbackTarget respondsToSelector:_valueChangeCallback]){
				[_callbackTarget performSelector:_valueChangeCallback withObject:self];
			}
		}
	}
	return _value;
}

-(float)getValue{
	return _value;
}


-(void)render
{
	[self normalizedValue];
	glColor4f(1,1,1,1);
	
	if(!_reverseDraw){
		[_upTexture drawInRect:upRect depth:-2.0f];
		[_overlayTexture drawInRect:_overlayRect depth:-2.0f];
	}else{
		[_overlayTexture drawInRect:_overlayRect depth:-2.0f];
		[_upTexture drawInRect:upRect depth:-2.0f];
	}
	
	glColor4f(1,1,1,1);
}

-(void)dealloc
{
	[_upTextureKey	release];
	[_downTextureKey release];
	[_overlayTextureKey release];
	[super dealloc];
}


@end
