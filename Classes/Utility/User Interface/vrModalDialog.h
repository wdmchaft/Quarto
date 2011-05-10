//
//  vrModalDialog.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/11/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrConstants.h"
#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "vrUIControl.h"
#import "glUtility.h"
#import "vrButton.h"
#import "vrTexturePool.h"
#import "glTextManager.h"
#import "vrTypeDefs.h"
#import "qrScreen.h"

@interface vrModalDialog : qrScreen{
	id				_parent;
	
	id				_acceptTarget;
	id				_declineTarget;
	id				_cancelTarget;
	
	SEL				_acceptSelector;
	SEL				_declineSelector;
	SEL				_cancelSelector;
	
	NSArray			*_buttons;
	NSMutableArray	*_textLines;
		
	vrButton		*_acceptButton;
	vrButton		*_declineButton;
	vrButton		*_cancelButton;
	vrButton		*_popButton;
	
	Texture2D		*_backing;
	Texture2D		*_buttonBacking;
	
	uint			_buttonCount;
	GLfloat			_buttonWidth;
	GLfloat			_buttonHeight;
	ControlRect		_windowRect;
	ControlRect		_originalWindowRect;
	
	Color3D			_textColour;
	float			_textHeight;
	float			_textWidth;
}

@property (nonatomic, retain) NSMutableArray *textLines;

-(void)configureWithProperties:(NSDictionary *)properties;

-(void)setAcceptTarget:(id)target withSelector:(SEL)selector;
-(void)setDeclineTarget:(id)target withSelector:(SEL)selector;
-(void)setCancelTarget:(id)target withSelector:(SEL)selector;


-(void)buttonAccept:(vrButton *)button;
-(void)buttonDecline:(vrButton *)button;
-(void)buttonCancel:(vrButton *)button;

-(ControlRect)controlRectForPosition:(int)p;

-(void)drawView:(EAGLView *)view clear:(BOOL)clear;

@end

