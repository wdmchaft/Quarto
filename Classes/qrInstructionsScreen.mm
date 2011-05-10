//
//  qrInstructionsScreen.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-09.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrInstructionsScreen.h"


@implementation qrInstructionsScreen

-(void)nextPage:(vrButton *)sender
{
	if(_currentPage < ([_pages count] - 1))
		_currentPage++;
	
	if(_currentPage == [_pages count] -1)[_elements removeObject:_acceptButton];
	
	if(![_elements containsObject:_cancelButton])[_elements addObject:_cancelButton];
}

-(void)lastPage:(vrButton *)sender
{
	if(_currentPage)
		_currentPage--;
	
	if(!_currentPage)[_elements removeObject:_cancelButton];
	
	if(![_elements containsObject:_acceptButton])[_elements addObject:_acceptButton];
}	

-(void)screenWillLoad
{
	_currentPage = 0;
	[_elements removeObject:_cancelButton];
	if(![_elements containsObject:_acceptButton])[_elements addObject:_acceptButton];
}

-(void)buttonAccept:(vrButton *)button{
	if(_acceptTarget && _acceptSelector){
		if([_acceptTarget respondsToSelector:_acceptSelector]){
			[_acceptTarget performSelector:_acceptSelector];
		}else{
			LOG(NSLog(@"MODAL DIALOG ERROR (Accept):Target Does Not Respond to Selector"));
		}
	}else{
		LOG(NSLog(@"MODAL DIALOG ERROR (Accept): Target and/or Selector Not Set"));
	}
	//[_viewController dismissDialog];
}

-(void)buttonCancel:(vrButton *)button{
	if(_cancelTarget && _cancelSelector){
		if([_cancelTarget respondsToSelector:_cancelSelector]){
			[_cancelTarget performSelector:_cancelSelector];
		}else{
			LOG(NSLog(@"MODAL DIALOG ERROR (Cancel):Target Does Not Respond to Selector"));
		}
	}else{
		WARN(NSLog(@"MODAL DIALOG WARNING (Cancel): Target and/or Selector Not Set"));
	}
	//[_viewController dismissDialog];
}

-(void)setupUIElements
{
	[self setAcceptTarget:self withSelector:@selector(nextPage:)];
	[self setCancelTarget:self withSelector:@selector(lastPage:)];
		
	LOG(NSLog(@"Creating Instructions!"));
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Instructions" ofType:@"txt"];
	NSString *instructions = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
	
	if(!instructions){
		NSLog(@"Error - Could Not Find Instructions File");
		return;
	}
		
	NSArray *lines = [instructions componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray	*currentPage = nil;
	_pages = [[NSMutableArray alloc] initWithCapacity:[lines count]];
	
	for(NSString *line in lines){
		if([line hasPrefix:@"##"])continue;
		if([line hasPrefix:@"p>"])
		{
			//NSLog(@"Adding Page %d",[_pages count] +1);
			currentPage = [[NSMutableArray alloc] init];
			[_pages addObject:currentPage];
			[currentPage release];
			continue;
		}
		if([line hasPrefix:@"l>"])
		{
			if(!currentPage){NSLog(@"Error - found new line before a page break!"); continue;}
		
			NSString *subLine = [line substringFromIndex:2];
			NSArray *subLineParts = [subLine componentsSeparatedByString:@";"];
			if([subLineParts count] != 2){NSLog(@"Error - Wrong number of line components"); continue;}
			
			NSMutableDictionary *lineDict = [[NSMutableDictionary alloc] init];
			float height = [[subLineParts objectAtIndex:0] floatValue];
			[lineDict setObject:[NSNumber numberWithFloat:height] forKey:@"height"];
			[lineDict setObject:[subLineParts objectAtIndex:1] forKey:@"string"];
			
			//NSLog(@"  H: %f  String: %@",height,[subLineParts objectAtIndex:1]);
			
			[currentPage addObject:lineDict];
			[lineDict release];
			continue;
		}
	}
}


-(void)drawView:(EAGLView *)view clear:(BOOL)clear
{
	[super drawView:view clear:clear];
	
	//NSLog(@"Drawing Instructions...");
	
	if(!_pages)return;
	float top = 80;
	vrFontPerfs fp;
	fp.centered = NO;
	fp.color = Color3DMake(1,1,1,1);
	fp.scale = YES;
	
	float sc = 1.6;
	CGRect b = ScaledBounds();
	if(b.size.height == 1024)sc=1.3;
	
	glTextManager *tm = [glTextManager sharedTextManager];
	glEnable(GL_COLOR_MATERIAL);

	NSArray *page = [_pages objectAtIndex:_currentPage];
	for(NSDictionary *line in page){
		float height = [[line objectForKey:@"height"] floatValue];
		NSString *string = [line objectForKey:@"string"];
		fp.rect = CGRectMake(top,110,height*sc,40);
		
		[tm renderCharacterString:string withOptions:&fp];
		top+=(height+3);
	}
	glDisable(GL_COLOR_MATERIAL);
}

@end
