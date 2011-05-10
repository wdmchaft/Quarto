//
//  qrAIPlayer.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrAIMove.h"
#import "qrTypeDefs.h"

#define AILOGGING 0

#if AILOGGING
#define AILOG(__LOGMSG__)				__LOGMSG__
#else
#define AILOG(__LOGMSG__)				if(0)__LOGMSG__
#endif


@class qrBoardState;



@interface qrAIPlayer : NSObject {
	qrDifficulty		_difficulty;
	//qrBoardState		*_boardState;
}

//@property (nonatomic, retain) qrBoardState *boardState;

-(void)setDifficultyLevel:(qrDifficulty)difficulty;
-(void)calculateMove:(qrBoardState *)bs;
-(void)selectRandomPiece:(qrBoardState *)bs;

@end
