//
//  qrHomeScreen.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-28.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrHomeScreen.h"
#import "qrViewController.h"
#import "qrGameState.h"
#import "qrMultiPlayerSessonController.h"
#import "vrButton.h"

@implementation qrHomeScreen

-(void)screenWillLoad
{
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	if(!mps.peer)[mps setAvailability:NO];
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	vrButton *muteButton = (vrButton*)[self elementWithKey:@"MuteButton"];
	if(gs.muted)muteButton.forceOn = YES;
	else muteButton.forceOn = NO;
}

-(void)buttonSinglePlayer:(id)sender;
{
	LOG(NSLog(@"Single Player Button Pressed"));
	qrGameState *gs = [qrGameState sharedqrGameState];
	gs.gameType = singlePlayer;
	
	[_viewController setActiveScreenWithKey:@"SPGameScreen" withTransition:kFadeIn];
	
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	[mps disconnectAllPeers];
	[mps setAvailability:NO];
}


-(void)buttonTwoPlayer:(id)sender
{
	LOG(NSLog(@"Two Player Button Pressed"));
	qrGameState *gs = [qrGameState sharedqrGameState];
	gs.gameType = twoPlayerLocal;
	
	[_viewController setActiveScreenWithKey:@"GameScreen" withTransition:kFadeIn];
	
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	[mps setAvailability:NO];
	[mps disconnectAllPeers];

}

-(void)buttonNetworkGame:(id)sender
{
	LOG(NSLog(@"Network Game Button Pressed"));
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	gs.gameType = twoPlayerNetwork;
	[_viewController setActiveScreenWithKey:@"TPGameScreen" withTransition:kFadeIn];
	
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	if(!mps.peer)[mps setAvailability:YES];
}

-(void)buttonInstructions:(id)sender
{
	LOG(NSLog(@"How To Button Pressed"));
	[_viewController presentDialog:@"InstructionsDialog"];
}

-(void)buttonMute:(id)sender
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	vrButton *muteButton = (vrButton*)[self elementWithKey:@"MuteButton"];
	gs.muted = !gs.muted;
	
	if(gs.muted)muteButton.forceOn = YES;
	else muteButton.forceOn = NO;
	
}

@end
