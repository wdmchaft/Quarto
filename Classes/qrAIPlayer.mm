//
//  qrAIPlayer.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrAIPlayer.h"
#import "qrBoardState.h"
#import "glUtility.h"
#import "vrTypeDefs.h"

@implementation qrAIPlayer

//@synthesize boardState = _boardState;

static id anyPieceFromArray(NSArray *a)
{
	int c = [a count];
	if(0==c)return nil;
	int rnd = randomf()*c; if(rnd==c)rnd=0;
	return [a objectAtIndex:rnd];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		//TODO: Pull this from some cached gamestate
		_difficulty = kqrDifficultyEasy;
	}
	return self;
}

-(void)setDifficultyLevel:(qrDifficulty)difficulty
{
	_difficulty = difficulty;
}

-(void)selectRandomPiece:(qrBoardState *)bs
{
	NSArray *unplayedPieces = [bs unplayedPieces];
	int pieces = [unplayedPieces count];
	float rnd = randomf()*pieces; if(rnd==pieces)rnd=0;
	qrPiece *nextPiece = [unplayedPieces objectAtIndex:rnd];
	
	bs.selectedPiece = nextPiece;
	
	PostNotification(@"forceSelection");
	PostNotification(@"selectionLocked");
}


-(void)calculateMove:(qrBoardState *)bs
{
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];

	AILOG(NSLog(@"Running AI...."));
	
	BOOL isMainThread = [NSThread isMainThread];

	NSDate *d = [NSDate date];
	
	qrBoardState *boardState = bs;
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	qrDifficulty difficulty = gs.difficulty;
	
	float errorFactor = randomf();
	BOOL missMove= NO;
	BOOL randomMove=NO;
	
	switch(difficulty)
	{
		case kqrDifficultyEasy:
			if(randomf() < .5f)missMove = YES;
			if(randomf() < .5f)randomMove = YES;
			break;
		case kqrDifficultyMed:
			if(randomf() < .2f)missMove = YES;
			if(randomf() < .3f)randomMove = YES;
			break;
		default:
			break;
	}
	if(missMove)AILOG(NSLog(@"Miss Move enabled... %f", errorFactor));
	
	NSMutableArray *mBoard = [[NSMutableArray alloc] initWithArray:[boardState boardPositions]];
	NSMutableArray *unplayedPieces = [[NSMutableArray alloc] initWithArray:[boardState unplayedPieces]];
	NSMutableArray *possibleMoves = [[NSMutableArray alloc] init];
	
	
	qrAIMove	*nextMove = nil;
	qrPiece		*nextPiece = nil;
	/*
	  Check each available piece against each available position
			- Check if it's a winning move - save if it is
			- Check if when placed, check the number of pieces available that can be given that won't allow
				a win on the next move.
			- To choose a possible move:
				- Choose a winner if availalbe
				- Check all moves to see if one forces a win on the next selection regardless of placement
				- Choose a move with a next piece count of 1 or 3 if possible.  Randomly.
				- Randomly choose a move with with the highest piece count
	*/
	@synchronized(boardState){
	qrPiece *myPiece = boardState.selectedPiece;
	[unplayedPieces removeObject:myPiece];
	
	if(!myPiece)
		AILOG(NSLog(@"Error: AI - selected piece is nil"));
	
	int	winPositions[4];
	
	for(int i=0;i<16;i++)
	{
		qrPiece *pieceAtPosition = [boardState pieceAtPosition:i usingBoard:mBoard];
	
		
		if(!pieceAtPosition){
			[mBoard replaceObjectAtIndex:i withObject:myPiece];
			if([boardState checkForWin:mBoard result:winPositions])
			{
				qrAIMove *move = [[qrAIMove alloc] init];
				move.position = i;
				move.winningMove = YES;
				move.piece = myPiece;
				move.remainingPlayablePieces = 0;	
				[possibleMoves addObject:move];
				AILOG(NSLog(@"Detected Winning Move at Position %d",i));
				[move release];				
			}else{
				qrAIMove *move = [[qrAIMove alloc] init];
				int playablePieceCount = 0;
				for(qrPiece *p in unplayedPieces){
					BOOL canWin = NO;
					for(int j=0;j<16;j++){
						qrPiece *pieceAtPosition = [boardState pieceAtPosition:j usingBoard:mBoard];
						if(!pieceAtPosition){
							[mBoard replaceObjectAtIndex:j withObject:p];
							if([boardState checkForWin:mBoard result:winPositions]){
								canWin = YES;
							}
							[mBoard replaceObjectAtIndex:j withObject:[qrPiece nullPiece]];
						}
					}
					if(!canWin){
						playablePieceCount++;
						[move addPlayablePiece:p];
					}		
				}
				move.position = i;
				move.winningMove = NO;
				move.piece = myPiece;
				move.remainingPlayablePieces = playablePieceCount;	
				[possibleMoves addObject:move];
				[move release];	
			}
			[mBoard replaceObjectAtIndex:i withObject:[qrPiece nullPiece]];
		}
	}
	
	
	AILOG(NSLog(@"Calculated %d Possible Moves",[possibleMoves count]));
	
	//Iterate through all possible moves

		

	//Choose Winning Move
	
	for(qrAIMove *move in possibleMoves)
	{
		if(move.winningMove){
			nextMove = move;
			nextPiece = nil;
		}
		if(missMove && ([possibleMoves count] > 1)){
			AILOG(NSLog(@"Purposefully duffing our move..."));
			nextMove = nil;
		}
		if(nextMove)break;
	}
	
	if(randomMove && [unplayedPieces count]>1){
		nextMove = anyPieceFromArray(possibleMoves);
		nextPiece = [nextMove getPlayablePiece];
		if(!nextPiece)nextPiece = anyPieceFromArray(unplayedPieces);
		
		if(nextPiece){
			[mBoard replaceObjectAtIndex:nextMove.position withObject:nextPiece];
			if([boardState checkForWin:mBoard result:winPositions])nextPiece = nil;
		}
		[mBoard replaceObjectAtIndex:nextMove.position withObject:[qrPiece nullPiece]];
	}
		
		
	//Look for a move that will cause the player to lose regardless of piece choice...
	if(!nextMove){
		for(qrAIMove *move in possibleMoves)
		{
			if(nextMove || [unplayedPieces count]>15)break;  //Found a move/piece that forces a win
			//Iterate through all playable pieces for each move
			[mBoard replaceObjectAtIndex:move.position withObject:myPiece];
			for(qrPiece *p in move.playablePieces)
			{
				if(nextMove)break; //Found a move/piece that forces a win
				//Simulate the players next possible move
				BOOL willWin = YES;
				for(int i=0;i<16;i++)
				{
					qrPiece *pieceAtPosition = [boardState pieceAtPosition:i usingBoard:mBoard];
					if(pieceAtPosition)continue;
					//Now check all of the remaining pieces to see if the player is forced
					//to give us a winning piece
					for(qrPiece *np in unplayedPieces)
					{
						if(np == p)continue; //Don't replay the same piece...
						for(int j=0;j<16;j++){
							if([boardState pieceAtPosition:i usingBoard:mBoard])continue;
							[mBoard replaceObjectAtIndex:j withObject:np];
							BOOL res = [boardState checkForWin:mBoard result:winPositions];
							willWin = res && willWin;
							[mBoard replaceObjectAtIndex:j withObject:[qrPiece nullPiece]];
							if(!willWin)break;
						}
						if(!willWin)break;
					}
					if(!willWin)break;
				}
				//We found that we will win on the next turn regardless of what piece the player
				//picks if we place 
				if(willWin){
					AILOG(NSLog(@"We found a trap move!  Sorry suckers!"));
					nextMove = move;
					nextPiece = p;
					break;
				}
			}
			[mBoard replaceObjectAtIndex:move.position withObject:[qrPiece nullPiece]];
		}
	}
	//Haven't found anything interesting... Let's base the next move on
	//pice counts...
	

		
	if(!nextMove)
	{
		int lowPieceCount = 16;
		int highPieceCount = 0;
		qrAIMove *lowCountMove = nil;
		qrAIMove *highPieceMove = nil;
		
		NSMutableArray *_lowMoves = [[NSMutableArray alloc] initWithCapacity:16];
		NSMutableArray *_highMoves = [[NSMutableArray alloc] initWithCapacity:16];;
		
		for(qrAIMove *move in possibleMoves){
			if(move.remainingPlayablePieces < lowPieceCount){
				[_lowMoves removeAllObjects];
				lowPieceCount = move.remainingPlayablePieces;
				lowCountMove = move;
				[_lowMoves addObject:move];
			}
			if(move.remainingPlayablePieces == lowPieceCount){
				[_lowMoves addObject:move];
			}
			
			if(move.remainingPlayablePieces > highPieceCount){
				[_highMoves removeAllObjects];
				highPieceCount = move.remainingPlayablePieces;
				highPieceMove = move;
				[_highMoves addObject:move];
			}
			if(move.remainingPlayablePieces == highPieceCount){
				[_highMoves addObject:move];
			}
		}
			
		if(lowPieceCount==1 && lowCountMove){
			AILOG(NSLog(@"Found A Move With Low Count of 1"));
			nextMove = anyPieceFromArray(_lowMoves);
			nextPiece = [nextMove getPlayablePiece];
			if(!nextPiece){
				nextMove = nil;
			}
		}else{
			AILOG(NSLog(@"No obvious move - chossing highest count..."));
			nextMove = anyPieceFromArray(_highMoves);
			nextPiece = [nextMove getPlayablePiece];
			AILOG(NSLog(@"High Piece Move Position %d",nextMove.position));
			if(!nextPiece){
				nextMove = nil;
			}
		}
		[_lowMoves release];
		[_highMoves release];
	}
	
	if(!nextMove){
		AILOG(NSLog(@"Couldn't Find a Move - Choosing randomly"));
		if(![possibleMoves count]){
			AILOG(NSLog(@"Error: No possible moves!!!"));
		}else{
			int moves = [possibleMoves count];
			int rnd = randomf()*moves; if(rnd==moves)rnd=0;
			nextMove = [possibleMoves objectAtIndex:rnd];
			nextPiece = [nextMove getPlayablePiece];
			if(!nextPiece){
				if([unplayedPieces count]){
					int pieces = [unplayedPieces count];
					rnd = randomf()*pieces; if(rnd==pieces)rnd=0;
					nextPiece = [unplayedPieces objectAtIndex:rnd];
				}else {
					nextPiece = nil;
				}
			}
		}
	}
	
	//FailSafe	
	if(!nextPiece){
		if([unplayedPieces count]){
			nextPiece = [unplayedPieces objectAtIndex:0];
		}else {
			nextPiece = nil;
		}
	}	
		
	}//End syncronization block...
	
	AILOG(NSLog(@"AI Result: NextPiece %@ - Last Move Position:%d",[nextPiece fileNameFromProperties], nextMove.position));
	if(nextMove){
		[boardState aiMove:nextPiece position:nextMove.position];
		if(isMainThread){
			[boardState aiComplete];
			//[boardState placePiece:myPiece atPosition:nextMove.position];
			//boardState.selectedPiece = nextPiece;
		}
	}else{
		if(!nextMove)NSLog(@"Error: No Next Move calculated");
		if(!nextPiece)NSLog(@"Error: No Next Piece Selected");
	}
	
	[mBoard release];
	[possibleMoves release];
	[unplayedPieces release];	

	double et = -[d timeIntervalSinceNow];
	
	if(!isMainThread){
		NSTimeInterval pauseTime = 1.5-et;
		if(pauseTime >0)[NSThread sleepForTimeInterval:pauseTime];
	};

	
	[p release];
	AILOG(NSLog(@"Completing AI Loop"));
	if(!isMainThread)[NSThread exit];
}


@end
