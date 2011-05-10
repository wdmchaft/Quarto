//
//  vrButton.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 07/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrButton.h"


@implementation vrButton

-(id)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	if(self){
		if([properties objectForKey:@"callback"]){
			NSString *cbString = [properties objectForKey:@"callback"];
			SEL callback = NSSelectorFromString(cbString);
			[self setUpAction:callback];
		}
	}
	return self;
}

-(void)setDownAction:(SEL)selector
{
	_downAction = selector;
}


-(void)setUpAction:(SEL)selector
{
	_upAction = selector;
}

-(void)setMoveAction:(SEL)selector
{
	_moveAction = selector;
}

-(void)setTarget:(id)target
{
	_callbackTarget = target;
}

-(void)handleDownTouch	{
	if(!_callbackTarget){
		//NSLog(@"Error: vrButton Callback Target Not Set");
		return;
	}
	if([_callbackTarget respondsToSelector:_downAction])	{
		[_callbackTarget performSelector:_downAction withObject:self];		
	}
	else	{
		//NSLog(@"Error: vrButton upAction callback method not implemented");
	}
}

-(void)handleMoveTouch  {
	if(!_callbackTarget){
		//NSLog(@"Error: vrButton Callback Target Not Set");
		return;
	}
	if([_callbackTarget respondsToSelector:_moveAction])	{
		[_callbackTarget performSelector:_moveAction withObject:self];		
	}
	else	{
		//NSLog(@"Error: vrButton upAction callback method not implemented");
	}
	return;
}


-(vrTouchType)lastTouchType
{
	return _lastTouchType;
}

-(void)handleUpTouch:(vrTouchType)type
{
	
	//For a vrButton - type is generally ignored as all we care about is whether
	//the button was involved in a touch event - and not how that touch event went.
	
	_lastTouchType = type;
	
	if(!_callbackTarget){
		//NSLog(@"Error: vrButton Callback Target Not Set");
		return;
	}
	if([_callbackTarget respondsToSelector:_upAction])	{
		[_callbackTarget performSelector:_upAction withObject:self];		
	}
	else	{
		//NSLog(@"Error: vrButton upAction callback method not implemented");
	}
	
}

/*
-(void)renderControl
{
	NSLog(@"Rendered a vrButton!");
}
*/	

@end
