//
//  qrMultiPlayerSessonController.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrMultiPlayerSessonController.h"
#import "qrNetworkMove.h"

@implementation qrMultiPlayerSessonController

@synthesize peer = _peer;
@synthesize peerListHandler = _peerListHandler;
@synthesize dataDelegate = _dataDelegate;
@synthesize isServer = _isServer;
@synthesize connectingPeer = _connectingPeer;


SYNTHESIZE_SINGLETON_FOR_CLASS(qrMultiPlayerSessonController)

static BOOL arrayContainsStringObject(NSString *s, NSArray *a)
{
	for(NSString *st in a)
		if([s isEqualToString:st])return YES;
	return NO;	
}


-(void)dealloc
{
	self.peer = nil;
	[_session release];
	[super dealloc];
}

-(void)setAvailability:(BOOL)val
{
	_session.available = val;
}

- (BOOL) startPeer
{
    if (!_session) {
        _session = [[GKSession alloc] initWithSessionID:@"quartoGame" 
											displayName:nil
											sessionMode:GKSessionModePeer];
		[_session setDataReceiveHandler:self withContext:nil];
		
		_session.delegate			= self;
		_session.available			= NO;
		_session.disconnectTimeout	= 2;
		
		self.connectingPeer		= nil;
		self.peer				= nil;
		_isServer				= YES;
		_pingCount				= 0;
		_lastReturnedPingCount	= 0;
		_beatCount=0;
		
		ObserveNotification(self, @selector(disconnectAllPeers), @"DisconnectAllPeers");
		_heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(heartBeat:) userInfo:nil repeats:YES];
	}
	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
    return YES;
}

- (void) stopPeer
{
	[_heartBeatTimer invalidate];
	self.peer = nil;
	[_session disconnectFromAllPeers];
	[_session release];
	_session = nil;
}


- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer 
		   inSession: (GKSession *)session
			 context:(void *)context
{
	qrNetworkMove *m = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	if(m.isControlPacket){
		[self handleControlPacket:m];
	}else{
		[self.dataDelegate receiveData:m];
	}
	[m release];
}


- (BOOL)sendData:(NSData *)data
{
	//NSLog(@"Send Data Called...");
	NSArray *peers = [NSArray arrayWithObjects:self.peer, nil];
	NSError	*sendError;
	return [_session sendData:data toPeers:peers withDataMode:GKSendDataReliable error:&sendError];
}


-(void)heartBeat:(NSTimer *)timer
{
	if(!self.peer)return;
	
	if(!_isServer){
		_beatCount++;
		if(_beatCount > kMaxSyncError){
			LOG(NSLog(@"Detected 7 Beats Without A Ping... Disconnecting... "));
			[self disconnectAllPeers];
		}
		return;
	}
	else{
		if(_pingCount - _lastReturnedPingCount > kMaxSyncError){
			LOG(NSLog(@"Heartbeat Sync Off By More than 3 Beats... Disconnecting... "));
			[self disconnectAllPeers];
			return;
		}
		_pingCount ++;
		qrNetworkMove *cp = [[qrNetworkMove alloc] init];
		cp.isControlPacket = YES;
		qrNetControlData cd; cd.reply = NO; cd.pingCount=_pingCount;
		cp.netControlData = cd;
		
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject:cp];
		[self sendData:d];
		LOG(NSLog(@"Firing Hearbeat with count %d (%d)",cd.pingCount,_pingCount));
		[cp release];
	}
}


-(void)handleControlPacket:(qrNetworkMove *)m
{
	qrNetControlData cp = m.netControlData;

	if(_isServer){	//Set the last returned count....
		int pc = (m.netControlData).pingCount;
		_lastReturnedPingCount = pc;
	}else{
		LOG(NSLog(@"Hearbeat Recieved - Returning %d  (Beat Count %d)",cp.pingCount,_beatCount));
		cp.reply = YES;
		m.netControlData = cp;
		_beatCount = 0;
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject:m];
		[self sendData:d];
	}
}


-(void)disconnectAllPeers
{
	self.peer = nil;
	self.connectingPeer = nil;
	[_session disconnectFromAllPeers];
	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
	_pingCount = 0; _lastReturnedPingCount = 0; _beatCount = 0;
}


-(void)connectToPeer:(NSString *)peerID
{
	if(peerID != self.peer && peerID != self.connectingPeer){
		_session.available = NO;
		[_session disconnectFromAllPeers];
		[_peerListHandler clearTPBoard];
		self.connectingPeer = peerID;
		[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
		[_session connectToPeer:peerID withTimeout:20];
		_pingCount = 0; _lastReturnedPingCount = 0; _beatCount = 0;
	}
}


-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType == twoPlayerNetwork && !self.peer){
		LOG(NSLog(@"Accepting Connection From Peer %@",peerID));
		self.connectingPeer = peerID;
		[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
		[_peerListHandler displayAcceptDialog:peerID];
		_session.available = NO;
		_beatCount = 0;
	}else{
		//Already Connected... Decline the connection...		
		LOG(NSLog(@"Declining Connection (self.peer: %@) (self.connectingPeer %@)",self.peer, self.connectingPeer));
		[_session denyConnectionFromPeer:self.connectingPeer];
		[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
		self.connectingPeer = nil;
	}
}


-(void)acceptConnectionRequest
{
	NSError *acceptError;
	BOOL result = [_session acceptConnectionFromPeer:self.connectingPeer error:&acceptError];
	
	if(result){
		self.isServer = NO;
		self.peer = self.connectingPeer;
		self.connectingPeer = nil;
		LOG(NSLog(@"  Accept Connection Successful"));
		[_peerListHandler clearTPBoard];
		_pingCount = 0; _lastReturnedPingCount = 0; _beatCount = 0;
	}else{
		LOG(NSLog(@"  Accpet Connection Failed"));
		_session.available = YES;
	}
	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
}


-(void)declineConnectionRequest
{
	[_session denyConnectionFromPeer:self.connectingPeer];
	self.connectingPeer = nil;
	self.peer = nil;
	_session.available = YES;
	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
}



-(void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	LOG(NSLog(@"Session Failed!!!"));
	[self stopPeer];
	[self startPeer];
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	LOG(NSLog(@"Connection With Peer %@ Failed", peerID));
	self.peer = nil;
	self.connectingPeer = nil;
	self.isServer = YES;
	_session.available = YES;

	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
	[_peerListHandler displayConnectionFailedDialog:peerID];
}

-(void)dumpPeerStates
{
	NSArray *available = [_session peersWithConnectionState:GKPeerStateAvailable];
	NSArray *unavailable = [_session peersWithConnectionState:GKPeerStateUnavailable];
	NSArray *connected = [_session peersWithConnectionState:GKPeerStateConnected];
	
	printf("Available Peers:\n");
	for(NSString *s in available)
		printf("  %s\n",[[_session displayNameForPeer: s] UTF8String]);
	printf("Unavailable Peers:\n");
	for(NSString *s in unavailable)
		printf("  %s\n",[[_session displayNameForPeer: s] UTF8String]);
	printf("Connected Peers:\n");
	for(NSString *s in connected)
		printf("  %s\n",[[_session displayNameForPeer: s] UTF8String]);
	printf("Peer From QRMSC:");
	printf("  %s\n",[[_session displayNameForPeer: self.peer] UTF8String]);

	printf("Connecting Peer From QRMSC:");
	printf("  %s\n",[[_session displayNameForPeer: self.connectingPeer] UTF8String]);
}
	
-(NSArray *)peerIDsForUI
{
	NSArray *available = [_session peersWithConnectionState:GKPeerStateAvailable];

	NSMutableArray *ret = [[[NSMutableArray alloc] init] autorelease];
	
	NSString *deviceName = [[UIDevice currentDevice] name];
	
	for(NSString *peer in available){
		if([[_session displayNameForPeer:peer] isEqualToString:deviceName])continue;
		if(!arrayContainsStringObject(peer,ret))
			[ret addObject:peer];
	}
	if(self.peer)
		if(!arrayContainsStringObject(self.peer,ret))
			[ret addObject:self.peer];
	if(_connectingPeer)
		if(!arrayContainsStringObject(_connectingPeer,ret))
			[ret addObject:_connectingPeer];
	
	return ret;
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	@synchronized (self) {
		switch(state) {
			case GKPeerStateAvailable:
				LOG(NSLog(@"*********Peer %@ Became Available",peerID));
				break;
				
		   case GKPeerStateUnavailable:
				LOG(NSLog(@"**********Peer %@ Became UnAvailable",peerID));
				break;

			case GKPeerStateConnecting:
				LOG(NSLog(@"**********Peer %@ Connecting...",peerID));
				self.connectingPeer = peerID;
				break;	
				
			case GKPeerStateConnected:
				LOG(NSLog(@"***********Peer %@ Connected...",peerID));
				self.peer = peerID;
				self.connectingPeer = nil;
				[_peerListHandler displayGameConnectionSuccessDialog:self.peer];
				break;
				
			case GKPeerStateDisconnected:
				LOG(NSLog(@"************Peer %@ Disconnected",peerID));
				if(peerID == self.peer){
					PostNotification(@"MPPeerDisconnect");
					_session.available = YES;
					self.isServer = YES;
					self.peer = nil;
				}
				self.connectingPeer=nil;

				break;
		}
	}
   	[_peerListHandler updatePeers:[self peerIDsForUI] session:_session controller:self];
}
@end
