//
//  qrAnimation.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-28.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrAnimation.h"


@implementation qrAnimation

-(id)initWithAnimationSettings:(const qrAnimationSettings&)settings;
{
	self = [super init];
	if(self){
		s = settings;
	}
	return self;	
}

-(void)startAnimation
{
	_animating = YES;
	_animationComplete = NO;
	_translateComplete = YES;
	_scaleComplete = YES;
	
	_frames = s.duration * 20;
	_frameCount = 0;
	
	if(s.translate){
		_translateDelta = (1/(float)_frames)*(s.translateEnd - s.translateStart);
		_translateCurrent = s.translateStart;
		_translateComplete = NO;
	}
	if(s.scale){
		_scaleDelta = (1/(float)_frames)*(s.scaleEnd - s.scaleStart);
		_scaleComplete = NO;
	}
	if(s.easeOut){
		_frames *= .33;
	}
	
}

-(BOOL)updateAnimation
{
	//Update a whole shitload of properties
	if(s.easeOut){
		if(s.translate){
			_translateDelta = (1.0f/_frames)*(s.translateEnd - _translateCurrent);
			_translateCurrent = s.translateStart;
		}
		if(s.scale){
			_scaleDelta = (1.0f/_frames)*(s.scaleEnd - _scaleCurrent);
		}
		_frameCount++;
		if(_frameCount >= (_frames*2))_animating = NO;
	}else{
		_frameCount++;
		if(_frameCount >= _frames)_animating = NO;
	}
	
	_translateCurrent = _translateCurrent + _translateDelta;
	_scaleCurrent = _scaleCurrent + _scaleDelta;
	
	return (_animating);
}

-(void)translateAndScale
{
	if(s.translate)
		glTranslatef(_translateCurrent.x, _translateCurrent.y, _translateCurrent.z);
	if(s.scale)
		glScalef(_scaleCurrent, _scaleCurrent, _scaleCurrent);
	
}

-(void)renderGlow
{
	if(_glowComplete || !s.glow)return;
	glColor4f(_glowCurrentColor.red, _glowCurrentColor.green, _glowCurrentColor.blue, _glowCurrentColor.alpha);
	if(s.glowTexture){
		//TODO Scale this
		CGRect r = s.glowRect;
		[s.glowTexture drawInRect:r depth:s.glowZDepth];
	}
	glColor4f(1,1,1,1);
}



@end
