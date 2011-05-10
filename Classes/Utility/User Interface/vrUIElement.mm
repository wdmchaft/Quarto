//
//  vrUIElement.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrUIElement.h"


@implementation vrUIElement

@synthesize depth = _depth;
@synthesize key = _key;
@synthesize hide = _hide;

-(id)initWithProperties:(NSDictionary *)properties
{
	self = [super init];
	if(self){
		_hide = NO;
		_autoScale = NO;
		
		if([properties objectForKey:@"autoScale"])
			_autoScale = [[properties objectForKey:@"autoScale"] boolValue];
		if([properties objectForKey:@"depth"])
			_depth = [[properties objectForKey:@"depth"] intValue];
	}
	return self;
}

-(void)dealloc
{
	[_key release]; _key=nil;
	[super dealloc];
}

-(NSComparisonResult)sortByDepth:(vrUIElement *)element
{
	if(self.depth < element.depth)return NSOrderedDescending;
	if(self.depth == element.depth)return NSOrderedSame;
	else return NSOrderedAscending;
}

-(void)render
{
	return;
}

-(bool)checkDownTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	return false;
}

-(bool)checkMoveTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	return false;
}

-(bool)checkUpTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;
{
	return false;
}

@end
