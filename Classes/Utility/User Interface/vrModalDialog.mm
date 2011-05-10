//
//  vrModalDialog.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/11/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrModalDialog.h"
#import "NSString+vectorParse.h"
#import "qrViewController.h"

@implementation vrModalDialog

@synthesize textLines = _textLines;


-(void)configureWithProperties:(NSDictionary *)properties
{	
	
	[super configureWithProperties:properties];
	
	if([properties objectForKey:@"acceptSelector"]){
		NSString *asString = [properties objectForKey:@"acceptSelector"];
		_acceptSelector = NSSelectorFromString(asString);		
	}
	
	if([properties objectForKey:@"buttonCount"]){
		_buttonCount = [[properties objectForKey:@"buttonCount"] intValue];
	}else{
		_buttonCount = 0;
		WARN(NSLog(@"MODAL DIALOG WARNING: Button Count Initialized to Zero"));
	}	
		
	if([properties objectForKey:@"buttonWidth"]){
		_buttonWidth = [[properties objectForKey:@"buttonWidth"] floatValue];
	}else{
		_buttonWidth = 100;
		WARN(NSLog(@"MODAL DIALOG WARNING: buttonWidth Initialized to Default"));
	}
	
	if([properties objectForKey:@"buttonHeight"]){
		_buttonHeight = [[properties objectForKey:@"buttonHeight"] floatValue];
	}else{
		_buttonHeight = 25;
		WARN(NSLog(@"MODAL DIALOG WARNING: buttonHeight Initialized to Default"));
	}
	
	if([properties objectForKey:@"windowRect"]){
		_windowRect = [[properties objectForKey:@"windowRect"] controlRectFromCDS];
	}else{
		_windowRect = ControlRectMake(100,220,400,80);	
		WARN(NSLog(@"MODAL DIALOG WARNING: windowRect Initialized to Default"));
	}
	
	if([properties objectForKey:@"strings"]){
		self.textLines = [[NSMutableArray alloc] initWithArray:[properties objectForKey:@"strings"]];
	}
	
	int buttonCountCheck = 0;
	
	if([properties objectForKey:@"acceptButton"]){
		ControlRect cR = [self controlRectForPosition:1];
		_acceptButton = [[vrButton alloc] initWithProperties:[properties objectForKey:@"acceptButton"]];
		[_acceptButton setRects:cR];
		[_acceptButton setTarget:self];
		[_acceptButton setUpAction:@selector(buttonAccept:)];
		[_elements addObject:_acceptButton];
		buttonCountCheck++;
	}
	
	if([properties objectForKey:@"popButton"]){
		_popButton = [[vrButton alloc] initWithProperties:[properties objectForKey:@"popButton"]];
		[_popButton setTarget:self];
		[_popButton setRects:_windowRect];
		[_popButton setUpAction:@selector(buttonAccept:)];
		[_elements addObject:_popButton];
		buttonCountCheck++;
	}
	
	if([properties objectForKey:@"declineButton"]){
		ControlRect cR = [self controlRectForPosition:2];
		_declineButton = [[vrButton alloc] initWithProperties:[properties objectForKey:@"declineButton"]];
		[_declineButton setRects:cR];
		[_declineButton setTarget:self];
		[_declineButton setUpAction:@selector(buttonDecline:)];
		[_elements addObject:_declineButton];
		buttonCountCheck++;
	}
	
	if([properties objectForKey:@"cancelButton"]){
		ControlRect cR = [self controlRectForPosition:3];
		_cancelButton = [[vrButton alloc] initWithProperties:[properties objectForKey:@"cancelButton"]];
		[_cancelButton setRects:cR];
		[_cancelButton setTarget:self];
		[_cancelButton setUpAction:@selector(buttonCancel:)];
		[_elements addObject:_cancelButton];
		buttonCountCheck++;
	}
	
	
	if(_buttonCount != buttonCountCheck){
		WARN(NSLog(@"MODAL DIALOG WARNING: Button Count Does not match the number of defined buttons"));
	}
	
	
	_originalWindowRect = _windowRect;
	
	
	CGRect bounds = ScaledBounds();
	_windowRect.top *= bounds.size.height/480.0f;
	_windowRect.bottom *= bounds.size.height/480.0f;
	_windowRect.left *= bounds.size.width/320.0f;
	_windowRect.right *= bounds.size.width/320.0f;
	
	_bounds = CGRectFromControlRect(_windowRect);
	
	_acceptTarget = _viewController;
	_declineTarget = _viewController;
	_cancelTarget = _viewController;
	
	return;
}

-(ControlRect)controlRectForPosition:(int)p
{
	if(!_buttonCount){
		LOG(NSLog(@"MODAL DIALOG ERROR: Button Count is Zero"));
		return _windowRect;
	}
	
	/****************
	
			LEFT
	+-+-----------------+
	| |                 |
	|o|                 |  TOP
	| | Acc  Decl  Canc |
	+-+-----------------+
			RIGHT
	 
	 ****************/
	
	ControlRect cR;
	cR.left = _windowRect.right - _buttonHeight - 10;
	cR.right= _windowRect.right - 10;
	
	GLfloat top		= _windowRect.top;
	GLfloat	bottom	= _windowRect.bottom;
	GLfloat center	= bottom + p * (top - bottom) / (_buttonCount + 1);
	
	cR.top		= center-_buttonWidth/2.2;
	cR.bottom	= center+_buttonWidth/2.2;
	//printf("Setting CR For Modal Button (%f,%f,%f,%f)/n",cR.left,cR.right,cR.top,cR.bottom);
	return cR;
}


-(void)setAcceptTarget:(id)target withSelector:(SEL)selector{
	_acceptTarget = target;
	_acceptSelector = selector;
}
	
-(void)setDeclineTarget:(id)target withSelector:(SEL)selector{
	_declineTarget = target;
	_declineSelector = selector;
}

-(void)setCancelTarget:(id)target withSelector:(SEL)selector{
	_cancelTarget = target;
	_cancelSelector = selector;
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
	[_viewController dismissDialog];
}

-(void)buttonDecline:(vrButton *)button{
	if(_declineTarget && _declineSelector){
		if([_declineTarget respondsToSelector:_declineSelector]){
			[_declineTarget performSelector:_declineSelector];
		}else{
			LOG(NSLog(@"MODAL DIALOG ERROR (Decline):Target Does Not Respond to Selector"));
		}
	}else{
		WARN(NSLog(@"MODAL DIALOG WARNING (Decline): Target and/or Selector Not Set"));
	}
	[_viewController dismissDialog];
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
	[_viewController dismissDialog];
}

-(void)renderText{
	glTextManager *tM = [glTextManager sharedTextManager];
	//Draw Our Text Here...
	vrFontPerfs p;
	p.color = Color3DMake(kTextModalColour);
	p.centered = true;
	p.shadowOffset = 1.5;
	p.scale = YES;
	
	//Debug
	GLfloat column = _originalWindowRect.left + 5;
	for(NSString *line in _textLines){
		GLfloat center = (_originalWindowRect.top+_originalWindowRect.bottom)/2;
		CGRect rect = CGRectMake(column, center - 6*[line length], 24, 12*[line length]);
		//iPadScaleRect(&r);
		p.rect = rect;
		
		[tM renderCharacterString:line withOptions:&p];
		//[tM renderCharacterString:line inRect:rect withShadowOffset:1.5 centered:true];
		column+=20; 
	}	
	glColor4f(1,1,1,1);
}


//GLView Delegate Methods

-(void)drawView:(EAGLView *)view clear:(BOOL)clear
{
	glColor4f(1,1,1,1);
	if(self.backingTextureKey){
		Texture2D *t = [[vrTexturePool sharedvrTexturePool] objectForKey:self.backingTextureKey];
		[t drawInRect:_bounds];
	}
	for(vrUIElement *e in _elements)[e render];
	[self renderText];
}


-(void)dealloc{
	[_textLines release];
	[_buttons release];
	[_acceptButton release];
	[_cancelButton release];
	[_declineButton release];
	[_popButton release];
	[_textLines release];
	[super dealloc];
}

@end
