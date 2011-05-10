//
//  vrTransitionHandler.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-15.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "vrTransitionHandler.h"
#import "glUtility.h"

@implementation vrTransitionHandler

-(id)initWithType:(vrTransitionType)type frames:(int)frames
{
	self = [super init];
	if(self){
		_type = type;
		_frames = frames;
		_currentFrame = 0;
		_bounds = ScaledBounds();
		[self setup];
	}
	return self;
}

-(void)setup
{
	switch(_type)
	{
		case kSlideRight:
			_hTranslate = 0;
			_hTDelta = -_bounds.size.height / (float)_frames;
			_hStart = _bounds.size.height ;
			break;
		case kSlideLeft:
			_hTranslate = 0;
			_hTDelta = _bounds.size.height  / (float)_frames;
			_hStart = -_bounds.size.height ;
			break;
		case kFadeIn:
			_hTranslate = 0;
			_hTDelta = 0;
			_hStart = 0;
			
			_fadeFrames = _frames/2;
		default:
			break;	
	}
}


-(bool)transitionFrom:(qrScreen	*)from to:(qrScreen *)to view:(EAGLView *)view
{
	glClearColor(0.2f, 0.2f, 0.2f, 1.0f); 
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	gluSetDefault2DStates();
	gluSetDefault2DProjection();
	if(_type==kSlideLeft || _type==kSlideRight){
		glPushMatrix();
		glTranslatef(0, _hTranslate, 0);
		[from drawView:view clear:false];
		glPopMatrix();
		glPushMatrix();	
		glTranslatef(0, _hStart+_hTranslate, 0);
		[to drawView:view clear:false];
		glPopMatrix();
		_hTranslate+=_hTDelta;
		_vTranslate+=_vTDelta;
	}
	else if(_type == kFadeIn){
		if(!from && !_currentFrame){
			_currentFrame = _fadeFrames;
		}
		if(_currentFrame<_fadeFrames){
			float c = 1 - (float)_currentFrame/(float)_fadeFrames;
			[from drawView:view clear:true];
			[from renderFader:c];
		}else{
			float c = (float)(_currentFrame-_fadeFrames)/(float)_fadeFrames;
			[to drawView:view clear:true];
			[to renderFader:c];
		}
	}
	
	_currentFrame++;
	
	if(_currentFrame == _frames)
		return false;
	else 
		return true;
}
@end
