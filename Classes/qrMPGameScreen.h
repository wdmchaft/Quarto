//
//  qrMPGameScreen.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrScreen.h"
#import "qrMultiPlayerSessonController.h"
#import "vrButton.h"

#define	kMaxButtons 4
#define kMaxPeerNameLength 22

#define SCROLLDEBUG 0

@interface qrMPGameScreen : qrScreen <qrPeerListHandler> {
	NSMutableArray	*_peerList;
	GKSession		*_session;
	NSMutableArray	*_peerButtons;
	NSMutableArray	*_peerNames;
	qrMultiPlayerSessonController *_sessionController;
	
	NSString		*_currentPeer;
	NSString		*_lastAttemptedPeer;
	
	int				_firstButtonIndex;
	int				_peerCount;
	BOOL			_canReset;
	BOOL			_shouldReset;
}

@property (retain) NSMutableArray *peerList;
@property (nonatomic, retain) qrMultiPlayerSessonController *sessionController;
@property (retain) NSString *currentPeer;
@property (retain) NSString *lastAttemptedPeer;


-(void)startGame:(vrButton *)sender;
-(void)resetTimer:(NSTimer *)t;

-(void)displayAcceptDialog:(NSString *)peerID;
-(void)displayConnectionFailedDialog:(NSString *)peerID;
-(void)displayGameConnectionSuccessDialog:(NSString *)peerID;

-(BOOL)updatePeers:(NSArray *)peers session:(GKSession *)session controller:(qrMultiPlayerSessonController*)ctrl;

-(void)displayConnected;
-(void)displayPicker;

-(void)scrollUp:(vrButton *)sender;
-(void)scrollDown:(vrButton *)sender;

-(void)selectPeer:(id)sender;
-(void)clearTPBoard;

-(void)disconnectFromPeers:(vrButton *)sender;

@end
