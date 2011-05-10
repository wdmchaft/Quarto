//
//  qrSinglePlayerGameScreen.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrSinglePlayerGameScreen.h"
#import "qrViewController.h"

@implementation qrSinglePlayerGameScreen

-(void)dealloc
{
	[_difficultyButtons release]; _difficultyButtons = nil;
	[_firstPlayButtons release]; _firstPlayButtons = nil;
	[super dealloc];
}

-(void)setupUIElements
{
	_easyButton = [self elementWithKey:@"Easy"];
	_medButton = [self elementWithKey:@"Medium"];
	_hardButton = [self elementWithKey:@"Hard"];
	_difficultyButtons = [[NSArray alloc] initWithObjects:_easyButton,_medButton,_hardButton,nil];

	_firstPlayerButton = [self elementWithKey:@"PlayerFirst"];
	_firstComputerButton = [self elementWithKey:@"ComputerFirst"];
	_firstRandomButton = [self elementWithKey:@"RandomFirst"];
	_firstPlayButtons = [[NSArray alloc] initWithObjects:_firstPlayerButton, _firstComputerButton, _firstRandomButton, nil];
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	int index = (int)gs.difficulty - 1;
	if(index < [_difficultyButtons count]){
		vrButton *cDif = [_difficultyButtons objectAtIndex:index];
		cDif.forceOn = YES;
	}else{
		NSLog(@"Error Setting Difficulty Button... Index: %d",index);
	}
	
	index = (int)gs.firstMove - 1;
	if(index < [_firstPlayButtons count]){
		vrButton *cDif = [_firstPlayButtons objectAtIndex:index];
		cDif.forceOn = YES;
	}else{
		NSLog(@"Error Setting First Move Button... Index: %d",index);
	}
	
	//TODO: Grab difficulty from game
}

-(void)startGame:(id)sender
{
	[_viewController setActiveScreenWithKey:@"GameScreen" withTransition:kFadeIn];
}

-(void)difficultyChanged:(vrButton *)sender
{
	for(vrButton *b in _difficultyButtons){
		b.forceOn = (b==sender);
	}
	qrGameState *gs = [qrGameState sharedqrGameState];
	if([_difficultyButtons containsObject:sender]){
		if([sender.key isEqualToString:@"Easy"])gs.difficulty = kqrDifficultyEasy;
		if([sender.key isEqualToString:@"Medium"])gs.difficulty = kqrDifficultyMed;
		if([sender.key isEqualToString:@"Hard"])gs.difficulty = kqrDifficultyHard;
		
		LOG(NSLog(@"Difficulty Set to %d",(int)gs.difficulty));
	}
}

-(void)firstPlayChanged:(vrButton *)sender
{
	for(vrButton *b in _firstPlayButtons){
		b.forceOn = (b==sender);
	}
	qrGameState *gs = [qrGameState sharedqrGameState];
	if([_firstPlayButtons containsObject:sender]){
		gs.firstMove = (qrFirstMove)([_firstPlayButtons indexOfObject:sender] + 1);
		//NSLog(@"Changed First Move to %d",(int)gs.firstMove);
	}
}

@end
