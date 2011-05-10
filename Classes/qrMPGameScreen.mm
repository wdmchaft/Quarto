//
//  qrMPGameScreen.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrMPGameScreen.h"
#import "vrButton.h"
#import "vrTextBox.h"
#import "qrViewController.h"

@implementation qrMPGameScreen

@synthesize peerList = _peerList;
@synthesize sessionController = _sessionController;
@synthesize currentPeer = _currentPeer;
@synthesize lastAttemptedPeer = _lastAttempedPeer;

-(void)dealloc
{
	self.peerList = nil;
	self.sessionController = nil;
	[_peerButtons release]; _peerButtons = nil;
	[_peerNames release]; _peerNames = nil;
	[super dealloc];
}

-(void)setupUIElements
{
	_peerCount = 0;
	[self displayPicker];
	_canReset = YES;
}

-(void)startGame:(vrButton *)sender
{
	if(_sessionController.peer){
		[self.viewController setActiveScreenWithKey:@"GameScreen" withTransition:kFadeIn];
	}else{
		if(_canReset){
			_canReset = NO;
			[_sessionController stopPeer];
			[_sessionController startPeer];
			[_sessionController setAvailability:YES];
			[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(resetTimer:) userInfo:nil repeats:NO];
		}
 	}
	@synchronized(_sessionController){
		//[_sessionController dumpPeerStates];
	}
}

-(void)resetTimer:(NSTimer *)t;
{
	_canReset = YES;
}


-(void)scrollDown:(vrButton *)sender
{
	if(_sessionController.peer)return;
	//NSLog(@"Scrolling Down");
	if((_firstButtonIndex + kMaxButtons) < _peerCount)++_firstButtonIndex;
	[self displayPicker];
}

-(void)scrollUp:(vrButton *)sender
{
	if(_sessionController.peer)return;
	//NSLog(@"Scrolling Up");
	if(_firstButtonIndex)--_firstButtonIndex;
	[self displayPicker];
}

-(void)screenWillLoad
{
	if(self.peerList){
		[self updatePeers:self.peerList session:_session controller:_sessionController];
	}
}

-(BOOL)updatePeers:(NSArray *)peers session:(GKSession *)session controller:(qrMultiPlayerSessonController*)ctrl;
{
	self.peerList = [NSMutableArray arrayWithArray:peers];
	
#if SCROLLDEBUG
	for(int i=0;i<6;i++){
		[self.peerList addObject:[NSString stringWithFormat:@"Dummy Entry %d",i]];	
	}
#endif
	
	_session = session;
	_sessionController=ctrl;
	LOG(NSLog(@"MPGameScreen Peers Updated!"));
	if(!_sessionController.peer){
		[self displayPicker];
	}else{
		[self displayConnected];
	}
	return YES;
}

-(void)displayConnected
{
	vrTextBox *tb = (vrTextBox *)[self elementWithKey:@"Heading"];
	tb.label = @"Connection Established";
	
	vrButton *pb = (vrButton *)[self elementWithKey:@"PlayButton"];
	pb.label = @"Resume";
	
	vrButton *su = (vrButton *)[self elementWithKey:@"ScrollUp"];
	su.hide = YES;
	
	vrButton *sd = (vrButton *)[self elementWithKey:@"ScrollDown"];
	sd.hide = YES;
	
	vrTextBox *nopeers = (vrTextBox *)[self elementWithKey:@"NoPeers"];
	nopeers.hide = YES;	
	
	@synchronized(self){
	
		if(!_peerButtons)_peerButtons = [[NSMutableArray alloc] init];
		if(!_peerNames)_peerNames = [[NSMutableArray alloc] init];
		
		[self.elements removeObjectsInArray:_peerButtons];
		[self.elements removeObjectsInArray:_peerNames];
		[_peerNames removeAllObjects];
		[_peerButtons removeAllObjects];
		
		NSMutableDictionary *perfs = [[NSMutableDictionary alloc] init];
		[perfs setObject:[NSNumber numberWithBool:YES] forKey:@"autoScale"];
		[perfs setObject:[NSNumber numberWithFloat:-5.0f] forKey:@"depth"];
		[perfs setObject:@"ButtonUp.png" forKey:@"textureKeyInactive"];
		[perfs setObject:@"ButtonDown.png" forKey:@"textureKeyActive"];
		[perfs setObject:[NSNumber numberWithFloat:.7] forKey:@"labelUpScale"];
		[perfs setObject:[NSNumber numberWithFloat:.6] forKey:@"labelDownScale"];
		
		NSString *rectString;
		float	top=135;
		float	height = 20;
		
		NSString *peerName =[_session displayNameForPeer:_sessionController.peer];
		
		rectString = [NSString stringWithFormat:@"%f,%f,200,380",top,top+height];
		[perfs setObject:rectString forKey:@"controlRect"];
		[perfs setObject:peerName forKey:@"label"];
		[perfs setObject:[NSNumber numberWithBool:NO] forKey:@"centerText"];
		
		vrTextBox *c = [[vrTextBox alloc] initWithProperties:perfs];
		[_peerNames addObject:c];	
		[c release];
		
		rectString = [NSString stringWithFormat:@"%f,%f,100,200",top,top+height];
		[perfs setObject:rectString forKey:@"controlRect"];
		
		[perfs setObject:@"Disconnect" forKey:@"label"];
		
		vrButton *b = [[vrButton alloc] initWithProperties:perfs];
		[b setDownAction:@selector(disconnectFromPeers:)];
		[b setTarget:self];
		b.key = _sessionController.peer;
		
		[_peerButtons addObject:b];
		[b release];
		top = top+height+1;
			
		[self.elements addObjectsFromArray:_peerButtons];
		[self.elements addObjectsFromArray:_peerNames];
		[self.elements sortUsingSelector:@selector(sortByDepth:)];
		[perfs release];
	}
}

-(void)displayPicker
{
	vrButton *su = (vrButton *)[self elementWithKey:@"ScrollUp"];
	su.hide = NO;
	if(!_firstButtonIndex)su.hide = YES;
	
	vrButton *sd = (vrButton *)[self elementWithKey:@"ScrollDown"];
	sd.hide = NO;
	if((_firstButtonIndex + kMaxButtons) > (_peerCount-1))sd.hide = YES;
	
	vrTextBox *tb = (vrTextBox *)[self elementWithKey:@"Heading"];
	tb.label = @"Choose Opponent...";
	
	vrButton *pb = (vrButton *)[self elementWithKey:@"PlayButton"];
	pb.label = @"Refresh";
	
	vrTextBox *nopeers = (vrTextBox *)[self elementWithKey:@"NoPeers"];
	if([self.peerList count] == 0 || !self.peerList){
		nopeers.hide = NO;
		tb.hide = YES;
	}else{
		nopeers.hide = YES;	
		tb.hide = NO;
	}
	
	@synchronized(self){
		if(!_peerButtons)_peerButtons = [[NSMutableArray alloc] init];
		if(!_peerNames)_peerNames = [[NSMutableArray alloc] init];
		
		[self.elements removeObjectsInArray:_peerButtons];
		[self.elements removeObjectsInArray:_peerNames];
		[_peerNames removeAllObjects];
		[_peerButtons removeAllObjects];
		
		NSMutableDictionary *perfs = [[NSMutableDictionary alloc] init];
		[perfs setObject:[NSNumber numberWithBool:YES] forKey:@"autoScale"];
		[perfs setObject:[NSNumber numberWithFloat:5.0f] forKey:@"depth"];
		[perfs setObject:@"ButtonUp.png" forKey:@"textureKeyInactive"];
		[perfs setObject:@"ButtonDown.png" forKey:@"textureKeyActive"];
		[perfs setObject:[NSNumber numberWithFloat:.7] forKey:@"labelUpScale"];
		[perfs setObject:[NSNumber numberWithFloat:.6] forKey:@"labelDownScale"];
		
		NSString *rectString;
		float	top=135;
		float	height = 20;
		
		_peerCount = [self.peerList count];
		
		int index = -1;
		
		for(NSString *peer in self.peerList)
		{
			NSString *peerName =[_session displayNameForPeer:peer];
			if(!peerName){--_peerCount; continue;}
			
			++index;
			if(index < _firstButtonIndex)continue;
			if(index >= (_firstButtonIndex + kMaxButtons))continue;
			
#if SCROLLDEBUG			
			if(!peerName)peerName = peer;
#endif
		
			NSString *peerNameMod = peerName;

			if([peerName length] > kMaxPeerNameLength)
				peerNameMod = [NSString stringWithFormat:@"%@...",[peerName substringToIndex:kMaxPeerNameLength-3]];
						
			rectString = [NSString stringWithFormat:@"%f,%f,200,380",top,top+height];
			[perfs setObject:rectString forKey:@"controlRect"];
			[perfs setObject:peerNameMod forKey:@"label"];
			[perfs setObject:[NSNumber numberWithBool:NO] forKey:@"centerText"];
			
			vrTextBox *c = [[vrTextBox alloc] initWithProperties:perfs];
			[_peerNames addObject:c];	
			[c release];
			
			rectString = [NSString stringWithFormat:@"%f,%f,100,200",top,top+height];
			[perfs setObject:rectString forKey:@"controlRect"];
			
			NSString *dispName;
			if([peer isEqualToString:_sessionController.peer]){
				dispName= @"Connected";
			}else if([peer isEqualToString:_sessionController.connectingPeer]){
				dispName= @"Connecting";
			}else{
				dispName = @"Connect";
			}
			
			[perfs setObject:dispName forKey:@"label"];
			
			vrButton *b = [[vrButton alloc] initWithProperties:perfs];
			[b setDownAction:@selector(selectPeer:)];
			[b setTarget:self];
			b.key = peer;
			b.depth = 4;
			
			[_peerButtons addObject:b];
			[b release];
			top = top+height+1;
			
		}
		[self.elements addObjectsFromArray:_peerButtons];
		[self.elements addObjectsFromArray:_peerNames];
		[self.elements sortUsingSelector:@selector(sortByDepth:)];
		[perfs release];
	}
}

-(void)displayAcceptDialog:(NSString *)peerID
{
	vrModalDialog *acd = (vrModalDialog*)[self.viewController screenForKey:@"TPAcceptDialog"];
	[acd setAcceptTarget:_sessionController withSelector:@selector(acceptConnectionRequest)];
	[acd setDeclineTarget:_sessionController withSelector:@selector(declineConnectionRequest)];
	
	NSMutableArray *textLines = acd.textLines;
	NSString *t = [NSString stringWithFormat:@"%@ ?",[_session displayNameForPeer:peerID]];
	[textLines replaceObjectAtIndex:1 withObject:t];
	
	[self.viewController purgeStack];
	[self.viewController presentDialog:@"TPAcceptDialog"];
}

-(void)displayConnectionFailedDialog:(NSString *)peerID
{
	if([self.viewController activeScreen] != self)return;
	
	vrModalDialog *cfd = (vrModalDialog*)[self.viewController screenForKey:@"TPConnectionFailed"];
	
	NSMutableArray *textLines = cfd.textLines;
	NSString *t = [NSString stringWithFormat:@"%@",[_session displayNameForPeer:peerID]];
	[textLines replaceObjectAtIndex:1 withObject:t];
	
	[self.viewController presentDialog:@"TPConnectionFailed"];
}

-(void)displayGameConnectionSuccessDialog:(NSString *)peerID
{
	vrModalDialog *bgd = (vrModalDialog*)[self.viewController screenForKey:@"TPBeginGame"];
	
	[bgd setAcceptTarget:self withSelector:@selector(startGame:)];
	
	NSMutableArray *textLines = bgd.textLines;
	NSString *t = [NSString stringWithFormat:@"%@",[_session displayNameForPeer:peerID]];
	[textLines replaceObjectAtIndex:1 withObject:t];

	[self.viewController purgeStack];
	[self.viewController presentDialog:@"TPBeginGame"];
	
}

-(void)disconnectFromPeers:(vrButton *)sender
{	
	[_sessionController disconnectAllPeers];
}

-(void)clearTPBoard
{
	qrGameScreen *gs = (qrGameScreen*)[self.viewController screenForKey:@"GameScreen"];
	[gs clearTwoPlayerBoard];	
}

-(void)selectPeer:(vrButton *)sender
{
	LOG(NSLog(@"Peer Selected %@",sender.key));
	LOG(NSLog(@"Attempting Connection"));
	
	[_sessionController connectToPeer:sender.key];
}


@end
