//
//  qrAIMove.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-27.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrAIMove.h"
#import "vrTypeDefs.h"

@implementation qrAIMove

@synthesize piece = _piece;
@synthesize position = _position;
@synthesize winningMove = _winningMove;
@synthesize remainingPlayablePieces = _remainingPlayablePieces;
@synthesize playablePieces = _playablePieces;

-(id)init
{
	self = [super init];
	if(self)
	{
		_playablePieces = [[NSMutableArray alloc] init];
	}
	return self;
}


-(void)addPlayablePiece:(qrPiece *)p
{
	[_playablePieces addObject:p];
}

-(qrPiece*)getPlayablePiece
{
	if([_playablePieces count]){
		int moves = [_playablePieces count];
		int rnd = randomf()*moves; if(rnd==moves)rnd=0;
		LOG(NSLog(@"Retrieving Best Playable Piece"));
		return [_playablePieces objectAtIndex:rnd];
	}
	else {
		LOG(NSLog(@"Error - No playable pieces..."));
		return nil;
	}
}

-(void)dealloc
{
	[_playablePieces release];
	[super dealloc];
}


@end
