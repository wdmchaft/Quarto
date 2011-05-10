//
//  qrPiecePickerView.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrOrthoView.h"
#import "vrModelPool.h"
#import "qrBoardState.h"
#import "qrPieceView.h"

@interface qrPiecePickerView : qrOrthoView{
	NSMutableArray			*_pieceViews;
	
	qrBoardState			*_boardState;
	qrPieceView				*_lastPV;
}

-(id)initWithBoardState:(qrBoardState *)boardState;

-(void)updateViews;
//-(qrPiece *)checkPieceSelection:(CGPoint)p;
-(qrPiece *)checkPieceSelection:(CGPoint)p boardState:(id)boardState;
-(void)checkMoveSelection:(CGPoint)p;

-(void)forceSelection;
-(void)animatePieceSelection:(qrPieceView *)pV;


-(void)render;

@end
