//
//  qrGameState.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-28.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrGameState.h"


@implementation qrGameState

@synthesize difficulty = _difficulty;
@synthesize gameType = _gameType;
@synthesize firstMove = _firstMove;
@synthesize gameStats = _gameStats;
@synthesize screenFlipped = _screenFlipped;
@synthesize muted = _muted;

SYNTHESIZE_SINGLETON_FOR_CLASS(qrGameState);

-(id)init
{
	self = [super init];
	if(self){
		_screenFlipped = NO;
	}
	return self;
}

-(void)saveState
{
	NSMutableDictionary *state = [[NSMutableDictionary alloc] init];
	[state setObject:[NSNumber numberWithInt:(int)_difficulty] forKey:@"difficulty"];
	[state setObject:[NSNumber numberWithBool:_muted] forKey:@"muted"];
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:state forKey:@"QuartoState"];
	
	[_gameStats saveToUserDefaults:kStatsName];
	
	[state release];
}


-(void)loadState
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSDictionary *state = [[ud objectForKey:@"QuartoState"] retain];
	
	NSNumber *difficulty = [state objectForKey:@"difficulty"];
	if(difficulty)_difficulty = (qrDifficulty)[difficulty intValue];
	else _difficulty = kqrDifficultyEasy;
	
	NSNumber *savedMuted = [state objectForKey:@"muted"];
	if(savedMuted)_muted = [savedMuted boolValue];
	else _muted = NO;
	
	_firstMove = randomStart;
	
	self.gameStats = [qrGameStats loadFromUserDefaults:kStatsName];
	
	if(!self.gameStats){
		self.gameStats = [[qrGameStats alloc] init];
	}
	
	
	[state release];
}
@end
