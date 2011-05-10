//
//  qrPieceView.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrPieceView.h"


@implementation qrPieceView

@synthesize piece = _piece;
@synthesize selected = _selected;
@synthesize lockedIn = _lockedIn;
@synthesize animating = _animating;

@synthesize targetBounds = _targetBounds;
@synthesize currentBounds = _currentBounds;

-(void)animateToTarget:(CGRect)targetBounds frames:(int)frames linear:(BOOL)linear;
{
	_targetBounds = targetBounds;
	_animationFrames = (float)frames;
	_animating = YES;
	_frameCount = 0;
	_linear = linear;
	
	if(_linear){
		float dx = (_targetBounds.origin.x - _bounds.origin.x)/_animationFrames;
		float dy = (_targetBounds.origin.y - _bounds.origin.y)/_animationFrames;
		float dw = (_targetBounds.size.width - _bounds.size.width)/_animationFrames;
		float dh = (_targetBounds.size.height - _bounds.size.height)/_animationFrames;
		_deltaBounds = CGRectMake(dx,dy,dw,dh);
	}else{
		_animationFrames *= .33;
	}
	_currentBounds = _bounds;
}

-(void)resetBounds
{
	_currentBounds = _bounds;
}

-(void)render
{
	if(_animating){
		if(!_linear){
			float dx = (_targetBounds.origin.x - _currentBounds.origin.x)/_animationFrames;
			float dy = (_targetBounds.origin.y - _currentBounds.origin.y)/_animationFrames;
			float dw = (_targetBounds.size.width - _currentBounds.size.width)/_animationFrames;
			float dh = (_targetBounds.size.height - _currentBounds.size.height)/_animationFrames;
			_deltaBounds = CGRectMake(dx,dy,dw,dh);
			//if(dx<.05)_animating = NO;
		}
		else{
			_frameCount++;
			if(_frameCount==_animationFrames)_animating = NO;
		}
		float nx = _currentBounds.origin.x+_deltaBounds.origin.x;
		float ny = _currentBounds.origin.y+_deltaBounds.origin.y;
		float nw = _currentBounds.size.width+_deltaBounds.size.width;
		float nh = _currentBounds.size.height+_deltaBounds.size.height;
		_currentBounds = CGRectMake(nx,ny,nw,nh);
	}
}	

-(void)renderPiece
{
	vr3DModel *m = _piece.model;
	_rotation +=3;
	_slRotation +=.5;
	CGRect b = _currentBounds;
	CGPoint center = CGPointMake(b.origin.x+b.size.width*.80,b.origin.y+b.size.height/2);
	//gluSetDefault3DStates();
	glPushMatrix();
	glTranslatef(center.x, center.y, -200);
	float sf = b.size.width*.22;
	glScalef(sf,sf,sf);
	glRotatef(-50, 0, 1, 0);
	glRotatef(7, 1, 0, 0);
	if(_selected){
		glRotatef(_rotation, 0, 0, 1);
		gluSetDefault2DStates();
		CGRect r = CGRectMake(-2.f,-2.f,4.f,4.f);
		vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
		Texture2D *bu = [tp objectForKey:@"PieceBase.png"];
		glDepthMask(NO);
		if(bu)[bu drawInRect:r depth:-.02f];
		glDepthMask(YES);
		//gluDrawRect(r, 0.0f, &color, 2);
		gluSetDefault3DStates();
	}else{
		glRotatef(_slRotation, 0, 0, 1);
	}
	[m drawSelf];;
	//gluSetDefault2DStates();
	glPopMatrix();
}

@end
