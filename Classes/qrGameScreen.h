//
//  qrGameScreen.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrBoardState.h"
#import "qrPieceView.h"
#import "qrPiecePickerView.h"
#import "EAGLView.h"
#import "glTextManager.h"
#import "qrScreen.h"
#import "qrBoardRenderer.h"

@interface qrGameScreen : qrScreen{
	qrBoardState		*_boardState;
	qrBoard				*_board;
	qrPiecePickerView	*_pickerView;
	qrPieceView			*_selectedPieceView;
	qrBoardRenderer		*_boardRenderer;
	
	BOOL				_runAIOnNextRedraw;
}

-(id)initWithBoardState:(qrBoardState*)boardState;
-(void)createViews;
-(void)setBoardState:(qrBoardState *)boardState;

-(void)resetBoard:(id)sender;

-(void)clearTwoPlayerBoard;
-(void)opponentClearedBoard;
-(void)displayOQDialog;

-(qrPiece *)checkPieceSelection:(CGPoint)p;

-(void)drawView:(EAGLView *)view;


@end
