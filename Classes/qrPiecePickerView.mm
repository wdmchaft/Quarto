//
//  qrPiecePickerView.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrPiecePickerView.h"
#import "glUtility.h"
#import "vrAudioManager.h"

@implementation qrPiecePickerView

-(id)initWithBoardState:(qrBoardState *)boardState
{
	self = [super init];
	if(self){
		_boardState = boardState;
		_pieceViews = [[NSMutableArray alloc] initWithCapacity:16];
		
		ObserveNotification(self, @selector(updateViews), @"pieceQueueUpdated");
		ObserveNotification(self, @selector(forceSelection), @"forceSelection");
	}
	return self;
}


-(void)updateViews
{
	[_pieceViews removeAllObjects];
	
	float width = _bounds.size.width;
	float height = _bounds.size.height;
	
	float dx = width * .125;
	float dy = height *.5;
	
	float x = _bounds.origin.x;
	float y = _bounds.origin.y;
	
	for(qrPiece *p in [_boardState unplayedPieces])
	{
		qrPieceView *pieceView = [[qrPieceView alloc] init];
		pieceView.piece = p;
		[_pieceViews addObject:pieceView];
		
		CGRect pvBounds = CGRectMake(x,y,dx,dy);
		pieceView.bounds = pvBounds;
		[pieceView resetBounds];
		[pieceView release];
		
		//NSLog(@"Created Picker Sub View with Bounds (%f,%f,%f,%f)",x,y,dx,dy);
		
		y+=dy;
		if(y>=(height*.95)){
			y=_bounds.origin.y;
			x+=dx;
		}
	}
}


-(void)forceSelection
{
	if(_boardState.gameOver)return;
	LOG(NSLog(@"Forcing Selection..."));
	for(qrPieceView *pV in _pieceViews){
		if(pV.piece == _boardState.selectedPiece){
			pV.selected = YES;
			pV.lockedIn = YES;
			[self animatePieceSelection:pV];
			
			qrGameState *gs = [qrGameState sharedqrGameState];
			if(gs.gameType != singlePlayer){
				vrAudioManager *am = [vrAudioManager sharedvrAudioManager];
				[am playUISoundWithKey:@"Select"];
			}
			return;
		}
	}
	LOG(NSLog(@"Error: Forced selection can't find the piece you're forcing on it!!!"));
	return;	
}


-(qrPiece *)checkPieceSelection:(CGPoint)p boardState:(id)boardState
{
	//Iterate through piece views...  Return the piece that is selected.
	if(_boardState.gameOver)return nil;
	bool hit=NO;
	if([[qrGameState sharedqrGameState] screenFlipped]){
		CGRect b = ScaledBounds();
		p.x = b.size.width-p.x-10*ScreenScale();;
		p.y = b.size.height-p.y;
	}	
	for(qrPieceView *pV in _pieceViews){
		hit = [pV checkTouchPoint:p];
		if(hit){
			if(pV.selected){
				pV.lockedIn = YES;
				if([_boardState respondsToSelector:@selector(setSelectedPiece:)]){
					LOG(NSLog(@"Setting Selected Piece"));
					[_boardState performSelector:@selector(setSelectedPiece:) withObject:pV.piece];
					//PostNotification(@"selectionLocked");
					vrAudioManager *am = [vrAudioManager sharedvrAudioManager];
					[am playUISoundWithKey:@"Select"];
					_lastPV = nil;
				}
			}
			return pV.piece;
		}
	}
	for(qrPieceView *pV2 in _pieceViews){
		pV2.selected = NO;
		pV2.lockedIn = NO;
		[pV2 resetBounds];
	}
	return nil;
}

-(void)checkMoveSelection:(CGPoint)p
{
	if([[qrGameState sharedqrGameState] screenFlipped]){
		CGRect b = ScaledBounds();
		p.x = b.size.width-p.x-10*ScreenScale();;
		p.y = b.size.height-p.y;
	}		
	qrPieceView *currentPV = nil;
	for(qrPieceView *pV in _pieceViews){
		BOOL hit = [pV checkTouchPoint:p];
		if(hit){
			currentPV = pV;
			pV.selected = YES;
		}else{
			[pV resetBounds];
			pV.selected = NO;
			pV.animating = NO;
		}
	}	
	if(currentPV == _lastPV)return;
	
	//[_lastPV animateToTarget:_lastPV.bounds frames:4 linear:NO];
	[_lastPV resetBounds];
	_lastPV.selected = NO;
	
	_lastPV = currentPV;
	
	if(!currentPV)return;
	
	CGRect sb = ScaledBounds();
	CGRect targetBounds = CGRectMake(sb.origin.x+sb.size.width*.03, sb.origin.y+sb.size.height*.2, sb.size.width*.2, sb.size.height*.2);
	[currentPV animateToTarget:targetBounds frames:7 linear:NO];
	currentPV.selected = YES;
}

-(void)animatePieceSelection:(qrPieceView *)pV
{
	CGRect sb = ScaledBounds();
	CGRect targetBounds = CGRectMake(sb.origin.x+sb.size.width*.03, sb.origin.y+sb.size.height*.2, sb.size.width*.2, sb.size.height*.2);
	[pV animateToTarget:targetBounds frames:7 linear:NO];
}

-(void)render
{
	//Draw the background
	glDepthMask(GL_FALSE);
	[super render];
	
	//Draw all of the piece views
	for(qrPieceView *pV in _pieceViews){
		[pV render];
	}
	glDepthMask(GL_TRUE);
	gluSetDefault3DStates();
	for(qrPieceView *pV in _pieceViews){
		[pV renderPiece];
	}
	gluSetDefault2DStates();
}

@end
