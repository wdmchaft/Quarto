//
//  qrAnimation.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-28.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "vrMath.h"

struct qrAnimationSettings{
	float	duration;
	BOOL	easeOut;
	int		loopCount;
	
	BOOL	scale;
	float	scaleStart;
	float	scaleEnd;
	
	BOOL	translate;
	Vec3	translateStart;
	Vec3	translateEnd;
	
	BOOL	glow;
	
	Texture2D	*glowTexture;
	float		glowScaleStart;
	float		glowScaleEnd;
	Color3D		glowColorStart;
	Color3D		glowColorEnd;
	CGRect		glowRect;
	float		glowZDepth;
	
	qrAnimationSettings(){
		this->initialize();
	}
	
	void initialize(){
		scale		= NO;
		translate	= NO;
		glow		= NO;
		duration	= 0;
		easeOut	= NO;
		loopCount	= 0;
		//NSLog(@"Initialized an animation");
	}
	
	void Translation(const Vec3 &start, const Vec3 &end, const float mDuration){
		translateStart = start;
		translateEnd = end;
		translate = YES;
		duration = mDuration;
	}
	
	void Scale(const float start, const float end, const float mDuration){
		scaleStart = start;
		scaleEnd = end;
		duration = mDuration;
	}
};


@interface qrAnimation : NSObject {
	qrAnimationSettings		s;
	
	BOOL		_animating;
	BOOL		_animationComplete;
	int			_frameCount;
	float		_frames;
	
	Vec3		_translateCurrent;
	Vec3		_translateDelta;
	BOOL		_translateComplete;
	
	float		_scaleCurrent;
	float		_scaleDelta;
	BOOL		_scaleComplete;
	
	BOOL		_glowComplete;
	Color3D		_glowCurrentColor;
	Color3D		_glowColorDelta;
}

-(id)initWithAnimationSettings:(const qrAnimationSettings&)settings;
-(void)startAnimation;
-(BOOL)updateAnimation;
-(void)translateAndScale;
-(void)renderGlow;

@end
