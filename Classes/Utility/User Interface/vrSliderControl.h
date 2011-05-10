//
//  vrSliderControl.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 18/05/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrControl.h"
#import "vrTypeDefs.h"
#import "Texture2D.h"
#import "vrTexturePool.h"

typedef struct {
	CGRect			controlRect;
	vrOrientation	orientation;
	bool			zeroWhenReleased;
	float			recoilTime,;
	float			rangeMin;
	float			rangeMax;
	int				steps;
	Texture2D		*_sliderOverlayTexture;
}vrSliderControlDef;	


@interface vrSliderControl : vrControl {
	float				_value;					//Slider control value: 0 to 1
	vrSliderControlDef	_def;
	id					_callbackTarget;
	SEL					_valueChangeCallback;
	
	float				_recoilTime;			//If slider zeros - the time it takes to return to 0.  
		
	bool				_zeroWhenReleased;		//False by default...
	bool				_instantResponse;
	bool				_reverseDraw;
	vrOrientation		_orientation;
	
	//Texture2D			*_overlayTexture;
	//NSString			*_overlayTextureKey;
	bool				_fullOverlay;
	
	float				_overlayWidth;
	float				_overlayHeight;
	float				_backingSize;
	
}

@property (nonatomic) bool reverseDraw;

-(id)initWithProperties:(NSDictionary *)properties;

-(void)zeroWhenReleased:(bool)flag;
-(bool)setSliderOverlayTexture:(Texture2D *)texture;
-(void)setOrientation:(vrOrientation)orientation;
-(void)setRangeMin:(float)min max:(float)max steps:(int)steps;
-(void)setRecoilTime:(float)recoilTime;

-(float)value;
-(float)getValue;
-(void)setValue:(float)value;

-(float)normalizedValue;

//Callback Methods if the slider value changes...
-(void)setTarget:(id)target;
-(void)setValueChangeCallback:(SEL)selector;



@end
