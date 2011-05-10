//
//  qrBoardState.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrPiece.h"
#import "qrBoard.h"
#import "qrAIPlayer.h"
#import <GameKit/GameKit.h>
#import "UIDevice+machine.h"

@class qrMultiPlayerSessonController;

@interface qrBoardState : NSObject {
	NSMutableArray		*_boardPositions;
	NSMutableArray		*_pieces;
	NSMutableArray		*_piecesInPlay;
	NSMutableArray		*_piecesInQueue;

	qrPiece				*_selectedPiece;
	qrBoard				*_board;
	int					_currentPlayer;
	
	BOOL				_pieceSelectMode;
	BOOL				_piecePlaceMode;
	BOOL				_firstMove;
	
	BOOL				_gameOver;
	int					_winningPlayer;
	int					_winPositions[4];
	int					_lastPlacementPosition;
	
	NSThread			*_aiThread;
	qrAIPlayer			*_aiPlayer;
	qrPiece				*_nextAIPiece;
	int					_nextAIPosition;
	BOOL				_aiRunning;
	
	qrMultiPlayerSessonController *_MPSessionController;
	BOOL				_waitingForMove;
}

@property (nonatomic, assign) qrMultiPlayerSessonController *multiPlayerSessionController;
@property (assign) qrPiece *selectedPiece;
@property int currentPlayer;

@property BOOL aiRunning;
@property BOOL pieceSelectMode;
@property BOOL piecePlaceMode;

@property BOOL gameOver;
@property int winningPlayer;

@property BOOL waitingForMove;

-(id)init;
-(void)createPieces;

-(void)resetBoard;
-(void)startGame:(id)sender;
-(void)firstMove:(BOOL)flag;

-(NSString *)statusString;

-(qrBoard *)board;

-(BOOL)checkForWin;
-(BOOL)checkForWin:(NSArray *)board result:(int *)winPositions;
-(int*)winPositions;

-(void)placePiece:(qrPiece *)piece atPosition:(int)position;

-(void)runAI;
-(void)aiMove:(qrPiece *)p position:(int)pos;
-(void)aiComplete;
-(void)aiCompleteNotifications;
-(void)aiMoveAnimationComplete;

-(qrPiece *)pieceAtPosition:(int)position;
-(qrPiece *)pieceAtPosition:(int)position usingBoard:(NSArray *)board;
-(qrPiece *)pieceWithBitmask:(int)bitmask;

-(BOOL)isPositionFree:(int)position;

-(void)selectionLocked;

-(NSArray*)unplayedPieces;
-(NSArray*)boardPositions;

-(int)positionFromRow:(int)row column:(int)col;

- (void) receiveData:(id)data;

-(void)sendMove;
-(void)sendReset;

@end
