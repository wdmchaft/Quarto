//
//  qrSinglePlayerGameScreen.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrScreen.h"
#import "vrButton.h"

@interface qrSinglePlayerGameScreen : qrScreen {
	vrUIElement	*_easyButton,*_medButton,*_hardButton;
	vrUIElement	*_firstPlayerButton,*_firstComputerButton,*_firstRandomButton;
	NSArray		*_difficultyButtons, *_firstPlayButtons;
}

-(void)startGame:(id)sender;
-(void)difficultyChanged:(vrButton *)sender;
-(void)firstPlayChanged:(vrButton *)sender;

@end
