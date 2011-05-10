//
//  qrViewController.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrScreen.h"
#import "EAGLView.h"
#import "qrGameScreen.h"
#import "qrHomeScreen.h"
#import "vrTransitionHandler.h"
#import "vrModalDialog.h"

#define kFadeFrames 12

@interface qrViewController : NSObject <GLViewDelegate,TouchDelegate>{
	EAGLView				*_view;
	
	qrGameScreen			*_gameScreen;
	qrHomeScreen			*_homeScreen;
	
	NSMutableDictionary		*_screens;
	NSMutableArray			*_screenStack;
	
	qrScreen				*_activeScreen;
	qrScreen				*_lastScreen;
	vrModalDialog			*_dialog;
	
	vrTransitionHandler		*_th;
}


-(id)initWithGLView:(EAGLView *)view;

-(void)setActiveScreen:(qrScreen *)s;
-(BOOL)setActiveScreenWithKey:(NSString *)key;
-(BOOL)setActiveScreenWithKey:(NSString *)key withTransition:(vrTransitionType)t;
-(id)screenForKey:(NSString *)key;

-(void)dismissDialog;
-(void)presentDialog:(NSString *)key;

-(void)pushScreenWithKeyToStack:(NSString *)key;
-(void)popStack;
-(void)purgeStack;


-(qrScreen *)activeScreen;

-(void)fadeInActiveScreen;
-(void)clearView;

-(void)setGameScreen:(qrGameScreen *)gs;
-(void)loadUIScreens:(NSDictionary *)screens;

//Some Dialog Shit
-(void)switchToTPScreen;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 


@end
