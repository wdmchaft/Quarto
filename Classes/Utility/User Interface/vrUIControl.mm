//
//  vrUIControl.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 08/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrUIControl.h"


@implementation vrUIControl

@synthesize swipeTime	= _swipeTime;
@synthesize swipeLength	= _swipeLength;
@synthesize	swipeIncrement = _swipeIncrement;
@synthesize forceOn = _forceOn;
@synthesize disable				= _disable;

-(id)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	if(self){
		_bounds = ScaledBounds();
		_hsFactor = (_bounds.size.width + 2*kVPBar)/_bounds.size.width;
	}
	return self;
}


-(void)setDownAudioKey:(NSString *)key
{
	if(key){
		[_downAudioKey release];
		_downAudioKey = nil;
		_downAudioKey = [[NSString alloc] initWithString:key];
	}	
}


-(void)setUpAudioKey:(NSString *)key
{
	if(key){
		[_upAudioKey release];
		_upAudioKey = nil;
		_upAudioKey = [[NSString alloc] initWithString:key];

	}
}
	
-(void)setRect:(ControlRect)rect
{
	_cR = rect;
}
	
-(bool)checkTouch:(CGPoint)touch
{
	if(touch.x>_cR.left && touch.x<_cR.right && touch.y<_cR.bottom && touch.y>_cR.top)
		return true;
	return false;
}


//Note (x,y) is defined as the top left corner as 0,0
//with the device *unrotated*.  ControlRects for buttons
//to be defined in this way.

-(bool)checkDownTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{ 
	if(_disable)return false;
	//if(_isActive)return false;
	//qrGameState *gs = [qrGameState sharedqrGameState];
	
	CGPoint t = [touch locationInView:view];
	ScaleTouch(&t);


	CGRect b = ScaledBounds();

	if([[qrGameState sharedqrGameState] screenFlipped]){
		t.x = b.size.width-t.x-10*ScreenScale();
		t.y = b.size.height-t.y;
	}

	//NSLog(@"Touch Debug %f,%f",t.x,t.y);
	//NSLog(@"Scaled Bounds (%f,%f,%f,%f)",b.origin.x,b.origin.y,b.size.width,b.size.height);
	
	bool pressed = false;

	if(t.x>_cR.left && t.x<_cR.right && t.y<_cR.bottom && t.y>_cR.top)
	{
		_activeEvent		= event;
		_activeTouch		= touch;
		pressed				= true;
		_isActive			= true;
		touchStartLocation	= t;  //This control only allows one touch per control..
		touchCurrentLocation= t;
		touchEndLocation	= t;
		[_touchStartTime release];
		_touchStartTime = [[NSDate date] retain];
		_swipeIncrement = 0;
		_swipeLength	= 0;
		_swipeDirection = 0;
		[self handleDownTouch];
	}
	if(pressed && _downAudioKey){
		_aM = [vrAudioManager sharedvrAudioManager];
		int result = [_aM playUISoundWithKey:_downAudioKey];
		LOG(NSLog(@"Playing Control Sound %@ withResultCode:%d",_downAudioKey,result));
	}
	
	return pressed;
}

-(bool)checkMoveTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{ 
	if(_disable)return false;
	bool pressed = false;
	
	//qrGameState *gs = [qrGameState sharedqrGameState];
	
	CGPoint t = [touch locationInView:view];
	ScaleTouch(&t);

	
	if([[qrGameState sharedqrGameState] screenFlipped]){
		CGRect b = ScaledBounds();
		t.x = b.size.width-t.x-10*ScreenScale();;
		t.y = b.size.height-t.y;
	}
	
	if(touch==_activeTouch && event==_activeEvent)
	{
		pressed = true;
		_isActive = true;
		touchCurrentLocation= t;
		touchEndLocation	= t;
	
		float swipeLength = touchEndLocation.y - touchStartLocation.y;
		_swipeIncrement = swipeLength - _swipeLength;
		_swipeLength = swipeLength;
		
		
		if(_swipeDirection==0){
			if(_swipeLength >0)_swipeDirection = 1;
			else _swipeDirection=-1;
		}
		else{
			int swipeDir=-1;
			if(_swipeLength >0)swipeDir = 1;
			if(swipeDir != _swipeDirection){
				_swipeDirection = swipeDir;
				[_touchStartTime release];
				_touchStartTime = [[NSDate date] retain];
			}
		}
		[self handleMoveTouch];
	}
	
	return pressed;
}


-(bool)checkUpTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	if(_disable)return false;
	bool pressed = false;
	vrTouchType tt = kTouchSingle;
	//qrGameState *gs = [qrGameState sharedqrGameState];
	
	CGPoint t = [touch locationInView:view];
	ScaleTouch(&t);
	
	if([[qrGameState sharedqrGameState] screenFlipped]){
		CGRect b = ScaledBounds();
		t.x = b.size.width-t.x-10*ScreenScale();;
		t.y = b.size.height-t.y;
	}

	
	//Release the control - all touches are ended
	//if(touch.x>_cR.left && touch.x<_cR.right && touch.y<_cR.bottom && touch.y>_cR.top) 
	if(touch==_activeTouch && event==_activeEvent)
	{
		pressed					= true;
		touchCurrentLocation	= t;
		touchEndLocation		= t;
		
		_isActive		= false;
		_wasReleased	= true;
		_activeEvent	= nil;
		
		_swipeLength = touchEndLocation.y - touchStartLocation.y;
		float swipeLengthV = touchEndLocation.x - touchStartLocation.x;
		
		//float touchYDelta = touchEndLocation.y - touchStartLocation.y;
		//NSLog(@"Touch Y Delta: %f",touchYDelta);
		//TODO:Add logic to determine touch type here
		if(_swipeLength>20)tt= kTouchSwipeRight;
		else if(_swipeLength<-20)tt=kTouchSwipeLeft;
		
		else if(swipeLengthV>20)tt=kTouchSwipeDown;
		else if(swipeLengthV<-20)tt=kTouchSwipeUp;
		
		_swipeTime = -[_touchStartTime timeIntervalSinceNow];
		
		[self handleUpTouch:tt];
	}
	if((pressed && _upAudioKey)){
		if(!_soundOnSwipe || (_soundOnSwipe && (tt==kTouchSwipeLeft || tt==kTouchSwipeRight))){
			_aM = [vrAudioManager sharedvrAudioManager];
			[_aM playUISoundWithKey:_upAudioKey];
		}
	}
	return pressed;	
	[_touchStartTime release];
}



//Base Class does not handle its own touch events... Implement these in any
//Inheriting classes to define specific behavior when a touch is detected...
//Example: Call a call-back function, check which element was selected, etc.
//Called AUTOMATICALLY when a touch is detected!

-(void)handleDownTouch	{return;}
-(void)handleMoveTouch  {return;}
-(void)handleUpTouch:(vrTouchType)type {return;}



-(UIEvent *)activeEvent{
	return _activeEvent;
}

-(bool)wasReleased{
	return _wasReleased;
}

-(bool)isActive{
	return _isActive;
}


-(void)clearStates
{
	_isActive	= false;
	_wasReleased= false;
	_activeEvent= nil;
}


//Typically Overridden by inheriting classes.
-(void)render
{
	return;   //No-op from the base class
}


-(void)dealloc{
	[_upAudioKey release];
	[_downAudioKey release];
	[super dealloc];
}

@end
