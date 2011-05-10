//
//  qrMultiPlayerSessonController.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "qrBoardState.h"
#import "SynthesizeSingleton.h"
#import "glUtility.h"

#define  kMaxSyncError 6

@protocol qrPeerListHandler;
@class qrNetworkMove;

@interface qrMultiPlayerSessonController : NSObject<GKSessionDelegate> {
	GKSession				*_session;
	NSMutableArray			*_peerList;
	id<qrPeerListHandler>	_peerListHandler;
	
	NSString				*_peer;
	NSString				*_connectingPeer;
	
	id						_dataDelegate;
	
	//YES if we initiated the connection.  
	//Server is responsible for sending heartbeats and monitoring connection state
	BOOL					_isServer;
	
	NSTimer					*_heartBeatTimer;
	int						_beatCount;
	int						_pingCount;
	int						_lastReturnedPingCount;
}

@property (retain) NSString *peer;
@property (nonatomic, assign) id<qrPeerListHandler> peerListHandler;
@property (assign) id dataDelegate;
@property BOOL isServer;
@property (retain) NSString *connectingPeer;

+(qrMultiPlayerSessonController *)sharedqrMultiPlayerSessonController;

-(BOOL) startPeer;
-(void) stopPeer;
-(NSArray *)peerIDsForUI;

-(void)disconnectAllPeers;
-(void)setAvailability:(BOOL)val;

-(void)heartBeat:(NSTimer *)timer;
-(void)handleControlPacket:(qrNetworkMove *)m;

-(BOOL)sendData:(NSData *)data;
-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
-(void)connectToPeer:(NSString *)peerID;

//Callbacks for ListHandler...
-(void)acceptConnectionRequest;
-(void)declineConnectionRequest;

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;
-(void)session:(GKSession *)session didFailWithError:(NSError *)error;
-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error;
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state;

@end

@protocol qrPeerListHandler<NSObject>

-(BOOL)updatePeers:(NSArray *)peers session:(GKSession *)session controller:(qrMultiPlayerSessonController*)ctrl;
-(void)displayAcceptDialog:(NSString *)peerID;
-(void)displayConnectionFailedDialog:(NSString *)peerID;
-(void)displayGameConnectionSuccessDialog:(NSString *)peerID;
-(void)clearTPBoard;

@end


