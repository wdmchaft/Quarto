//
//  qrAppController.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-24.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrBoardState.h"
#import "qrBoardRenderer.h"
#import "qrGameScreen.h"
#import "qrPlayer.h"
#import "qrAIPlayer.h"
#import "vrModelPool.h"
#import "vrTexturePool.h" 
#import "EAGLView.h"
#import "vrConstants.h"
#import "glUtility.h"
#import "qrViewController.h"
#import "qrGameTextureController.h"
#import "qrMultiPlayerSessonController.h"

@interface qrAppController : NSObject <TouchDelegate, GLViewDelegate, UIAccelerometerDelegate > {
	EAGLView			*_view;
	
	qrBoardState		*_boardState;
	qrPlayer			*_player;
	qrAIPlayer			*_AIplayer;
	qrBoard				*_board;
	qrBoardRenderer		*_boardRenderer;
	qrGameScreen		*_gameScreen;
	
	qrViewController	*_viewController;
	qrGameTextureController *_textureController;
	qrMultiPlayerSessonController *_mpSessionController;
	
	BOOL				_pieceSelectMode;
	BOOL				_piecePlaceMode;
	
	TouchProperties		_tp;
	
	BOOL				_flip;
}

-(id)initWithView:(EAGLView *)view;
-(void)createBoard;

-(void)loadModels;
-(void)loadTextures;

-(void)freeAllTextures;
-(void)reloadTextures;

-(void)forceMainScreen;
-(void)fadeIn;
-(void)clearView;


//TouchDelegate Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 

//Render Delegate
-(void)drawView:(EAGLView*)view;


@end
