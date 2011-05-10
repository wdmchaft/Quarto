//
//  vrButton.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 07/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrControl.h"
#import "Texture2D.h"
#import "vrTypeDefs.h"

@interface vrButton : vrControl {
	SEL			_downAction;
	SEL			_upAction;
	SEL			_moveAction;
	id			_callbackTarget;
	
	vrTouchType _lastTouchType;
	
}

-(void)setDownAction:(SEL)selector; 
-(void)setMoveAction:(SEL)selector;
-(void)setUpAction:(SEL)selector;
-(void)setTarget:(id)target;

-(vrTouchType)lastTouchType;

-(void)handleDownTouch;
-(void)handleMoveTouch;
-(void)handleUpTouch:(vrTouchType)type;

@end
