//
//  vrTransitionHandler.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-15.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrScreen.h"
#import "EAGLView.h"

typedef enum {
	kNone = 1,
	kSlideLeft,
	kSlideRight,
	kSlideUp,
	kSlideDown,
	kFadeIn,
}vrTransitionType;


@interface vrTransitionHandler : NSObject {
	float	_hTranslate,  //Horizontal Translation
			_vTranslate;  //Vertical Translation
	
	float	_hStart,
			_vStart;
	
	float	_hTDelta,	//Horizontal Translation Delta
			_vTDelta;	//Vertical Translation Delta
	
	float	_fadeColor;
	int		_fadeFrames;
	
	vrTransitionType	_type;
	int					_frames;
	int					_currentFrame;
	
	CGRect				_bounds;
}

-(id)initWithType:(vrTransitionType)type frames:(int)frames;
-(void)setup;

-(bool)transitionFrom:(qrScreen	*)from to:(qrScreen *)to view:(EAGLView *)view;

@end
