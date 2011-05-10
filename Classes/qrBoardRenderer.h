//
//  qrBoardRenderer.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "vrModelPool.h"
#import "vrMath.h"
#import "qrBoardState.h"
#import "qrBoard.h"


@interface qrBoardRenderer : NSObject <GLViewDelegate>{
	float			_zRot;
	qrBoard			*_board;
	qrBoardState	*_boardState;
	
	float			_pieceRotation;
}

@property (nonatomic) float rotationAngle;
@property (nonatomic,assign) qrBoardState *boardState;
@property (nonatomic,assign) qrBoard *board;


-(void)drawView:(EAGLView*)view;
-(void)setProjection:(EAGLView *)view;
-(void)drawPieces;
-(void)drawBoard;
-(void)drawTest;

@end
