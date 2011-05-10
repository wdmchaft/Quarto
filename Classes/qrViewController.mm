//
//  qrViewController.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrViewController.h"
#import "UIDevice+machine.h"

@implementation qrViewController


-(id)initWithGLView:(EAGLView *)view
{
	self = [super init];
	if(self)
	{
		_view = view;
		_screens = [[NSMutableDictionary alloc] init];
		_activeScreen = nil;
		_dialog = nil;
		ObserveNotification(self, @selector(displayOQDialog),@"MPPeerQuit" );
		_screenStack = [[NSMutableArray alloc] init];
		
	}
	return self;
}

-(void)dealloc
{
	[_gameScreen release]; _gameScreen = nil;
	[_activeScreen release]; _activeScreen = nil;
	[_screens release];
	[_screenStack release];
	[super dealloc];
}

						
-(void)setGameScreen:(qrGameScreen *)gs
{
	[_gameScreen release];
	_gameScreen = [gs retain];
	[_screens setObject:gs forKey:@"GameScreen"];
}

-(void)setActiveScreen:(qrScreen *)s
{
	[_activeScreen release];
	_activeScreen = [s retain];
	[s screenWillLoad];
}

-(qrScreen *)activeScreen
{
	return _activeScreen;
}

-(id)screenForKey:(NSString *)key
{
	return [_screens objectForKey:key];
}

-(BOOL)setActiveScreenWithKey:(NSString *)key
{
	qrScreen *s = [_screens objectForKey:key];
	if(s){
		[self setActiveScreen:s];
		return YES;
	}
	NSLog(@"Error: Could Not Set Screen With Key %@",key);
	return NO;
}

-(BOOL)setActiveScreenWithKey:(NSString *)key withTransition:(vrTransitionType)t
{
	_th = [[vrTransitionHandler alloc] initWithType:t frames:kFadeFrames];
	_lastScreen = _activeScreen;
	return [self setActiveScreenWithKey:key];
}

-(void)fadeInActiveScreen{
	[_th release];
	_th = [[vrTransitionHandler alloc] initWithType:kFadeIn frames:kFadeFrames];
	_lastScreen = nil;
}

-(void)pushScreenWithKeyToStack:(NSString *)key
{
	qrScreen *s = [self screenForKey:key];
	[_screenStack addObject:s];
}

-(void)popStack
{
	[_screenStack removeLastObject];
}

-(void)purgeStack
{
	[_screenStack removeAllObjects];
}

-(void)presentDialog:(NSString *)key
{
	qrScreen *s = [self screenForKey:key];
	
	//Don't push the same dialog twice...
	if([_screenStack lastObject] != s){
		[self pushScreenWithKeyToStack:key];
	}
	_dialog = (vrModalDialog *)s;
	[s screenWillLoad];

}

-(void)switchToTPScreen
{
	[self dismissDialog];
	[self setActiveScreenWithKey:@"TPGameScreen" withTransition:kFadeIn];
}

-(void)dismissDialog
{
	[self popStack];
	_dialog = nil;
}

-(void)clearView{
	[_activeScreen renderFader:0];
}

-(void)loadUIScreens:(NSDictionary *)screens
{
	for(NSString *screenKey in screens){
		NSDictionary *screenDef = [screens objectForKey:screenKey];
		
		NSDictionary *elements = [screenDef objectForKey:@"UIElements"];
		NSString *screenClass = [screenDef objectForKey:@"class"];

	
		if(!screenClass){
			//WARN(NSLog(@"Error: No Class Found For %@",screenKey));
			continue;
		}
		
		id screen = [[NSClassFromString(screenClass) alloc] initWithController:self];
		
		if([screen isKindOfClass:NSClassFromString(@"qrScreen")])
		{
			[screen configureWithProperties:screenDef];
			if(elements)
				[screen performSelector:@selector(loadUIElementsFromDictionary:) withObject:elements];
			[screen setupUIElements];
		}else{
			NSLog(@"Error: %@ Does Not Inherit from qrScreen",screenClass);
			[screen release];
			continue;
		}
		[_screens setObject:screen forKey:screenKey];
		[screen release];
	}
	
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	if(_th)return;
	qrScreen *s = _activeScreen;
	if([_screenStack count])s=[_screenStack lastObject];
	
	[s touchesBegan:touches withEvent:event withView:view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	if(_th)return;
	qrScreen *s = _activeScreen;
	if([_screenStack count])s=[_screenStack lastObject];
	[s touchesMoved:touches withEvent:event withView:view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	if(_th)return;
	qrScreen *s = _activeScreen;
	if([_screenStack count])s=[_screenStack lastObject];
	[s touchesEnded:touches withEvent:event withView:view];
}

-(void)drawView:(EAGLView *)view
{
	if(_th){
		gluSetDefault2DStates();
		gluSetDefault2DProjection();
		bool transitioning = [_th transitionFrom:_lastScreen to:_activeScreen view:view];
		if(!transitioning){
			[_th release];
			_th = nil;
		}
	}else{
		gluSetDefault2DStates();
		gluSetDefault2DProjection();
		[_activeScreen drawView:view];
		for(qrScreen *s in _screenStack)[s drawView:view];
		
		//if(_dialog)[_dialog drawView:view];
	}
}


@end
