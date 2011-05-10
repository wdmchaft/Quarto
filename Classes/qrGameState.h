//
//  qrGameState.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-28.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "qrTypeDefs.h"
#import "qrGameStats.h"

#define kStatsName @"DefaultQuartoStats"

@interface qrGameState : NSObject {
	qrGameType		_gameType;
	qrDifficulty	_difficulty;
	qrFirstMove		_firstMove;
	
	BOOL			_screenFlipped;
	BOOL			_muted;
	
	qrGameStats		*_gameStats;
}

@property qrGameType gameType;
@property qrDifficulty difficulty;
@property qrFirstMove firstMove;
@property BOOL screenFlipped;
@property (retain) qrGameStats *gameStats;
@property BOOL muted;

+(qrGameState*)sharedqrGameState;

-(void)saveState;
-(void)loadState;

@end
