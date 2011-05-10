//
//  qrAIMove.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-27.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrPiece.h"


@interface qrAIMove : NSObject {
	qrPiece			*_piece;
	int				_position;
	BOOL			_winningMove;
	int				_remainingPlayablePieces;
	
	NSMutableArray	*_playablePieces;
}

@property (nonatomic, assign) qrPiece *piece;
@property (nonatomic) int position;
@property (nonatomic) BOOL winningMove;
@property (nonatomic) int remainingPlayablePieces;
@property (nonatomic, readonly) NSArray *playablePieces;

-(void)addPlayablePiece:(qrPiece *)p;
-(qrPiece*)getPlayablePiece;

@end
