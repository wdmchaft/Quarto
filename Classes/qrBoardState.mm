//
//  qrBoardState.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrBoardState.h"
#import "glUtility.h"
#import "qrAIPlayer.h"
#import "vrTypeDefs.h"
#import "qrNetworkMove.h"
#import "qrMultiPlayerSessonController.h"
#import "vrAudioManager.h"

@implementation qrBoardState

@synthesize multiPlayerSessionController = _MPSessionController;

@synthesize selectedPiece = _selectedPiece;
@synthesize currentPlayer = _currentPlayer;
@synthesize piecePlaceMode = _piecePlaceMode;
@synthesize pieceSelectMode = _pieceSelectMode;

@synthesize gameOver = _gameOver;
@synthesize winningPlayer = _winningPlayer;
@synthesize waitingForMove = _waitingForMove;
@synthesize aiRunning = _aiRunning;

static void invertBitMask(unsigned char *mask, int length)
{
	unsigned char ret = 0;
	for(int i=0;i<length;i++){
		char testBit = 1<<i;
		bool bit = !((*mask) & testBit);
		
		if(bit)ret += testBit;
	}
	*mask = ret;	
}

-(id)init
{
	self = [super init];
	if(self){
		_boardPositions = [[NSMutableArray alloc] initWithCapacity:16];
		_piecesInPlay	= [[NSMutableArray alloc] initWithCapacity:16];
		[self createPieces];
		[self resetBoard];
		_board = [[qrBoard alloc] init];
		
		_aiPlayer = [[qrAIPlayer alloc] init];
		//_aiPlayer.boardState = self;
		ObserveNotification(self, @selector(selectionLocked), @"selectionLocked");
	}
	return self;
}

-(void)dealloc
{
	[_boardPositions release];
	[_piecesInPlay release];
	[_piecesInQueue release];
	[_board release];
	[_pieces release];
	[super dealloc];
}

-(void)createPieces
{
	[_pieces release];
	_pieces = [[NSMutableArray alloc] initWithCapacity:16];
	
	for(unsigned char i=0;i<16;i++){
		qrPiece *p = [[qrPiece alloc] initFromBitMask:i];
		[_pieces addObject:p];
	}
}


-(void)resetBoard
{
	if(_aiRunning)return;
	//Reset everything
	[_boardPositions removeAllObjects];
	
	for(int i =0;i<16;i++){
		[_boardPositions addObject:[qrPiece nullPiece]];
	}
	
	[_piecesInPlay removeAllObjects];
	
	[_piecesInQueue release];
	_piecesInQueue = [[NSMutableArray alloc] initWithArray:_pieces];
	
	PostNotification(@"pieceQueueUpdated");
	
	_currentPlayer = 0;
	_piecePlaceMode = NO;
	_pieceSelectMode = YES;
	_gameOver = NO;
	_firstMove = YES;
	_nextAIPiece = nil;
	_nextAIPosition = 0;
	_winningPlayer = 2;
	self.selectedPiece = nil;
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	
	if(gs.gameType == twoPlayerNetwork){
		_waitingForMove = _MPSessionController.isServer;
		if(_waitingForMove)_currentPlayer = 1;
	}
	else
		_waitingForMove = NO;
	
	if(gs.gameType == singlePlayer){
		if(gs.firstMove == randomStart)_currentPlayer = int(randomf()*2);
		if(gs.firstMove == playerStart)_currentPlayer = 0;
		if(gs.firstMove == computerStart)_currentPlayer = 1;
				
		//NSLog(@"Reset - First Player %d",_currentPlayer);
	}
}

-(void)startGame:(id)sender
{
	if(_currentPlayer){
		[_aiPlayer selectRandomPiece:self];
		_currentPlayer = 0;
		self.waitingForMove = NO;
	}
}


-(void)firstMove:(BOOL)flag
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType == twoPlayerNetwork){
		_waitingForMove = flag;
		if(flag)_currentPlayer = 1;
		else _currentPlayer = 0;
	}
}

-(BOOL)checkForWin
{
	return [self checkForWin:_boardPositions result:_winPositions];
}

-(BOOL)checkForWin:(NSArray *)board result:(int *)winPositions
{
	//Traverse Board looking for a win...
	int col, row;
	int position;
	unsigned char bitMask[4];
	int pieceCount;
	
	//Check Rows
	for(row=0;row<4;row++){
		pieceCount = 0;
		for(col=0;col<4;col++){
			position = [self positionFromRow:row column:col];
			qrPiece *p = [self pieceAtPosition:position usingBoard:board];
			if(p){
				bitMask[col] = [p bitMask];
				pieceCount++;
				winPositions[col] = position;
			}
		}
		if(pieceCount==4){
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//LOG(NSLog(@"Win Detected in Row %d",row));
				return YES;
			}
			for(int i=0;i<4;i++)invertBitMask(bitMask+i,4);
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//NSLog(@"Win Detected in Row %d",row);
				return YES;
			}
		}	
	}
	
	//Check Columns
	for(col=0;col<4;col++){
		pieceCount = 0;
		for(row=0;row<4;row++){
			position = [self positionFromRow:row column:col];
			qrPiece *p = [self pieceAtPosition:position usingBoard:board];
			if(p){
				bitMask[row] = [p bitMask];
				pieceCount++;
				winPositions[row] = position;
			}
		}
		//NSLog(@"Checked Column %d with count of %d",col+1,pieceCount);
		if(pieceCount==4){
			//for(int i = 0;i<4;i++)NSLog(@"BitMask %d is %d",i,bitMask[i]);
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//NSLog(@"Win Detected in Col %d",col);
				return YES;
			}
			for(int i=0;i<4;i++)invertBitMask(bitMask+i,4);
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//NSLog(@"Win Detected in Col %d",col);
				return YES;
			}
			
		}	
	}
	//Check Diagonals
	for(int count=0;count<2;count++){
		pieceCount = 0;
		for(int diag=0;diag<4;diag++){
			if(count==0){
				col = diag;
				row = diag;
			}else{
				col = diag;
				row = 3-diag;
			}
			position = [self positionFromRow:row column:col];
			qrPiece *p = [self pieceAtPosition:position usingBoard:board];
			if(p){
				bitMask[diag] = [p bitMask];
				pieceCount++;
				winPositions[diag] = position;
			}
		}
		//NSLog(@"Checked Column %d with count of %d",col+1,pieceCount);
		if(pieceCount==4){
			//for(int i = 0;i<4;i++)NSLog(@"BitMask %d is %d",i,bitMask[i]);
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//NSLog(@"Win Detected in Diagonal %d",count);
				return YES;
			}
			for(int i=0;i<4;i++)invertBitMask(bitMask+i,4);
			if(bitMask[0] & bitMask[1] & bitMask[2] & bitMask[3]){
				//NSLog(@"Win Detected in Diagonal %d",count);
				return YES;
			}
			
		}	
	}
	return NO;

}

-(qrPiece *)pieceWithBitmask:(int)bitmask
{
	for(qrPiece *p in _pieces){
		if([p bitMask] == bitmask)return p;
	}
	return nil;
}

-(qrBoard *)board
{
	return _board;
}

-(NSArray*)boardPositions
{
	return _boardPositions;
}

-(void)selectionLocked
{
	
	//NSLog(@"Locking In Selection for Player:%d",self.currentPlayer +1);
	_currentPlayer ? _currentPlayer = 0 : _currentPlayer = 1;
	self.pieceSelectMode = NO;
	self.piecePlaceMode = YES;
	
}

-(NSString *)statusString
{
	NSString *devString = [[UIDevice currentDevice] devicePrefix];
	NSString *s;
	int p = self.currentPlayer +1;
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	
	if(!self.gameOver){
		if(gs.gameType == twoPlayerLocal){
			if(!self.piecePlaceMode)
				s = [NSString stringWithFormat:@"Player %d Select Piece",p];
			else
				s = [NSString stringWithFormat:@"Player %d Place Piece",p];
		}
		
		if(gs.gameType == singlePlayer){
			if(!self.piecePlaceMode){
				if(!self.currentPlayer)
					s = [NSString stringWithFormat:@"Select Piece",p];
				else
					s = @"Thinking....";
			}
			else
				s = [NSString stringWithFormat:@"Place Piece",p];
		}
		
		if(gs.gameType == twoPlayerNetwork){
			if(self.waitingForMove){
				s= @"Waiting...";
			}else{
				if(!self.piecePlaceMode)
					s = [NSString stringWithFormat:@"Select Piece",p];
				else
					s = [NSString stringWithFormat:@"Place Piece",p];
			}
		}
	}
	
	if(self.gameOver){
		if(self.winningPlayer == 2)
			s = @"Draw";
		if(gs.gameType == singlePlayer  && self.winningPlayer==0)
			s = @"You Win!";
		if(gs.gameType == singlePlayer  && self.winningPlayer==1)
			s = [NSString stringWithFormat:@"%@ Wins!",devString];
		if(gs.gameType == twoPlayerLocal)
			s = [NSString stringWithFormat:@"Player %d Wins!",self.winningPlayer+1];
		if(gs.gameType == twoPlayerNetwork){
			if(self.winningPlayer == 0)s = @"You Win!";
			else s = @"You Lose!";
		}
	}
	if(self.aiRunning)s = @"Thinking....";
	
	return s;
}

#pragma mark - Networking

-(void)sendReset
{
	qrNetworkMove *m = [[qrNetworkMove alloc] init];
	
	m.resetBoard = YES;
	m.isControlPacket = NO;
	
	NSData *d = [NSKeyedArchiver archivedDataWithRootObject:m];
	[m release];
	
	LOG(NSLog(@"Sending Reset"));
	[_MPSessionController sendData:d];
}

-(void)sendMove
{
	qrNetworkMove *m = [[qrNetworkMove alloc] init];
	
	if(!_gameOver)
		m.nextPieceBitmask = [_selectedPiece bitMask];
	else
		m.nextPieceBitmask = 999;

	m.lastPiecePlacement = _lastPlacementPosition;
	
	NSData *d = [NSKeyedArchiver archivedDataWithRootObject:m];
	[m release];
	
	LOG(NSLog(@"Sending Move"));
	BOOL result = [_MPSessionController sendData:d];
	
	if(!result)NSLog(@"Error: Failed to send move...");
	
	_waitingForMove = YES;
	_firstMove = NO;
}


- (void) receiveData:(id)data
{
	qrNetworkMove *m = (qrNetworkMove*)data;
	
	qrPiece *p = [self pieceWithBitmask:m.nextPieceBitmask];
	
	LOG(NSLog(@"Recieved Data!  BitMask:  Position:"));
	
	if(m.resetBoard){
		PostNotification(@"OpponentResetBoard");
		return;
	}
	
	
	if(!_firstMove)[self placePiece:_selectedPiece atPosition:m.lastPiecePlacement];
	self.selectedPiece = p;
	_waitingForMove = NO;
	_firstMove = NO;

	PostNotification(@"forceSelection");
	PostNotification(@"selectionLocked");
}

#pragma mark - AI

-(void)runAI
{
	
	[_aiThread release];
	_aiThread = nil;
	self.waitingForMove = YES;
	
	
	_aiThread = [[NSThread alloc] initWithTarget:_aiPlayer
										selector:@selector(calculateMove:)
										  object:self];
	
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	[ns addObserver:self selector:@selector(aiComplete) name:@"NSThreadWillExitNotification" object:_aiThread];
	
	self.aiRunning = YES;
	[_aiThread start];
	
	//[_aiPlayer calculateMove:self];
}

-(void)aiMove:(qrPiece *)p position:(int)pos
{
	LOG(NSLog(@"AI Making Moving..."));
	_nextAIPiece = p;
	_nextAIPosition = pos;
}

-(void)aiComplete
{
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	[ns removeObserver:self name:@"NSThreadWillExitNotification" object:_aiThread];
	
	/*
	if([NSThread isMainThread]){
		NSLog(@"Completing AI on main thread");
	}else {
		NSLog(@"Completing AI from separate thread");
	}*/
	
	if(self.aiRunning){
		self.aiRunning = NO;
		[self performSelectorOnMainThread:@selector(aiCompleteNotifications)
							   withObject:nil
							waitUntilDone:NO];
	}
}	

	 
-(void)aiCompleteNotifications
{
	ObserveNotification(self, @selector(aiMoveAnimationComplete), @"PieceAnimationComplete");
	[self placePiece:_selectedPiece atPosition:_nextAIPosition];
	self.selectedPiece = _nextAIPiece;
}

-(void)aiMoveAnimationComplete
{
	LOG(NSLog(@"Animation Complete... Locking In Selection..."));
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	[ns removeObserver:self name:@"PieceAnimationComplete" object:nil];
	
	PostNotification(@"forceSelection");
	[self selectionLocked];
	
	self.waitingForMove = NO;
}

#pragma mark - Piece Positioning

-(void)placePiece:(qrPiece *)piece atPosition:(int)position
{
	if(!_gameOver){
		[_boardPositions replaceObjectAtIndex:position withObject:piece];
		[_piecesInQueue removeObject:piece];
		[_piecesInPlay addObject:piece];
		
		self.piecePlaceMode = NO;
		self.pieceSelectMode = YES;
		self.selectedPiece = nil;
		
		qrAnimationSettings s;
		s.Translation(Vec3(0,0,12),Vec3(0,0,0),.5);
		
		qrAnimation *a = [[qrAnimation alloc] initWithAnimationSettings:s];
		piece.placeAnimation = a;
		[a startAnimation];
		a.release;
		
		_lastPlacementPosition = position;
		PostNotification(@"pieceQueueUpdated");
	}
	
	//qrGameState *gameState = [qrGameState sharedqrGameState];
	
	BOOL win = [self checkForWin];
	if(win && !_gameOver){
		_gameOver = YES;
		_winningPlayer = _currentPlayer;
		vrAudioManager *am = [vrAudioManager sharedvrAudioManager];
		[am playUISoundWithKey:@"WinSound"];
	}
	if([_piecesInQueue count] == 0 && !win){
		//NSLog(@"Cats Game...");
		_gameOver = YES;
		_winningPlayer = 2;
	}
}

-(qrPiece *)pieceAtPosition:(int)position usingBoard:(NSArray *)board
{
	if(position > [board count]){
		NSLog(@"Error: Attempt to check board position out of range %d",position);
		return nil;
	}
	
	qrPiece *ret = [board objectAtIndex:position];
	if(ret.isNull)return nil;
	return ret;
	
}

-(int*)winPositions
{
	return _winPositions;
}

-(qrPiece *)pieceAtPosition:(int)position
{
	return [self pieceAtPosition:position usingBoard:_boardPositions];
}

-(BOOL)isPositionFree:(int)position
{
	qrPiece *p = [self pieceAtPosition:position];
	
	if(p)return NO;
	return YES;
}

-(NSArray*)unplayedPieces
{
	return _piecesInQueue;
}

-(int)positionFromRow:(int)row column:(int)col
{
	return row*4+col;
	//12 13 14 15
	//8  9  10 11
	//4  5  6  7
	//0  1  2  3
}

@end
