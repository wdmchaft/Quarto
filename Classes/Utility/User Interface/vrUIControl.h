//
//  vrUIControl.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 08/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "vrTypeDefs.h"
#import "vrAudioManager.h"
#import "qrGameState.h"
#import "vrUIElement.h"
#import "glUtility.h"



@interface vrUIControl : vrUIElement {
	ControlRect		_cR;
		
	bool		_isActive;		//Yes while a finger is down on the control
	bool		_wasReleased;	//Yes after a finger is raised but before clearStates is called
	UIEvent		*_activeEvent;	//* to the event that represents the current touch
	UITouch		*_activeTouch;
	
	bool		_soundOnSwipe;
	BOOL		_forceOn;
	
	float		_hsFactor;
	
	vrAudioManager	*_aM;
	NSString		*_downAudioKey;
	NSString		*_upAudioKey;
	
	CGPoint		touchStartLocation;
	CGPoint		touchCurrentLocation;
	CGPoint		touchEndLocation;	
	
	CGRect		_bounds;
	
	NSDate		*_touchStartTime;
	float		_swipeLength;
	float		_swipeIncrement;
	double		_swipeTime;
	int			_swipeDirection;

	
	bool		_disable;
}

@property (nonatomic) double swipeTime;
@property (nonatomic) float	 swipeLength;
@property (nonatomic) float  swipeIncrement;
@property (nonatomic) BOOL forceOn;
@property (nonatomic) bool disable;

-(void)setRect:(ControlRect)rect;
-(bool)checkTouch:(CGPoint)touch;		//Simple method that returns yes of a touch was within the reciever

-(void)setDownAudioKey:(NSString *)key;
-(void)setUpAudioKey:(NSString *)key;

-(void)handleDownTouch;
-(void)handleMoveTouch;
-(void)handleUpTouch:(vrTouchType)type;

-(void)clearStates;

-(UIEvent *)activeEvent;
-(bool)wasReleased;
-(bool)isActive;



@end
