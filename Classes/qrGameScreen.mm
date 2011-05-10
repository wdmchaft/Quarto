//
//  qrGameScreen.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrGameScreen.h"
#import "vrUIControl.h"
#import "qrViewController.h"
#import "vrTextBox.h"
#import "UIDevice+machine.h"

@implementation qrGameScreen

-(id)initWithController:(qrViewController *)viewController
{
	self = [super initWithController:viewController];
	if(self)
	{

	}
	return self;
}

-(id)initWithBoardState:(qrBoardState *)boardState
{
	self = [super init];
	if(self){
		[self setBoardState:boardState];
	}
	return self;
}

-(void)setBoardState:(qrBoardState *)boardState
{
	_boardState = boardState;
	_board = _boardState.board;
	
	_boardRenderer = [[qrBoardRenderer alloc] init];
	_boardRenderer.board = _board;
	_boardRenderer.boardState = _boardState;
	
	[self createViews];
}



-(void)createViews
{
	_pickerView = [[qrPiecePickerView alloc] initWithBoardState:_boardState];
	_selectedPieceView = [[qrPieceView alloc] init];
	
	CGRect bounds = ScaledBounds();
	CGRect pvBounds = CGRectMake(bounds.size.width*.02,bounds.size.height*.01,bounds.size.width*.95,bounds.size.height*.17);
	_pickerView.bounds = pvBounds;
	[_pickerView updateViews];
	_pickerView.backgroundTextureKey = @"PPBacking.png";
	
	DeviceType devType = [[UIDevice currentDevice] deviceType];
	NSString *uiLayoutFile = @"UILayout_iphone";
	if(devType == kiPadDevice)uiLayoutFile = @"UILayout_ipad";
	
	//NSLog(@"Using %@",uiLayoutFile);
	NSString *path = [[NSBundle mainBundle] pathForResource:uiLayoutFile ofType:@"plist"];
	NSDictionary *UILayout = [NSDictionary dictionaryWithContentsOfFile:path];
	NSDictionary *gsElements = [[UILayout objectForKey:@"GameScreen"] objectForKey:@"UIElements"];
	
	[self loadUIElementsFromDictionary:gsElements];
	
	ObserveNotification(self, @selector(opponentClearedBoard), @"OpponentResetBoard");
	ObserveNotification(self, @selector(displayOQDialog),@"MPPeerDisconnect");
}

-(void)displayOQDialog{
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType==twoPlayerNetwork){
		qrScreen *a = [self.viewController activeScreen];

		if(a == [self.viewController screenForKey:@"GameScreen"]){
			vrModalDialog *tpd = (vrModalDialog*)[self.viewController screenForKey:@"TPDisconnectDialog"];
			[tpd setAcceptTarget:self withSelector:@selector(buttonBack:)];
			
			[self.viewController presentDialog:@"TPDisconnectDialog"];
		}
	}
}


-(void)resetBoard:(id)sender
{
	//We cleared the board.  Called from a button press
	[_boardState resetBoard];
	[_boardState firstMove:YES];
	[_boardState sendReset];
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType == singlePlayer || gs.gameType == twoPlayerLocal){
		vrModalDialog *rd = (vrModalDialog *)[self.viewController screenForKey:@"SPReset"];
		[rd setAcceptTarget:_boardState withSelector:@selector(startGame:)];
		[self.viewController presentDialog:@"SPReset"];
	}
}

-(void)clearTwoPlayerBoard
{
	LOG(NSLog(@"Clear TP Board Called"));
	[_boardState resetBoard];
}

-(void)opponentClearedBoard
{
	//Your opponent Cleared... (Called via Notificaiton from the data recieve method)
	[_boardState resetBoard];
	[_boardState firstMove:NO];
	[self.viewController presentDialog:@"TPOpponentReset"];
}

-(void)screenWillLoad
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType == twoPlayerNetwork)
	{
		//Do Nothing.  The TPGameScreen will clear if needed....
	}else{
		//We're starting a single player game... Need to disconnect from multiplayer!
		PostNotification(@"DisconnectAllPeers");
		[_boardState resetBoard];
		[_boardState startGame:nil];
	}
}

-(qrPiece *)checkPieceSelection:(CGPoint)p
{
	if(_boardState.gameOver)return nil;
	return 	[_pickerView checkPieceSelection:p boardState:_boardState];
}

-(void)buttonBack:(id)sender
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	
	if(gs.gameType == singlePlayer){
		[self.viewController setActiveScreenWithKey:@"SPGameScreen" withTransition:kFadeIn];
		return;
	}
	if(gs.gameType == twoPlayerNetwork){
		[self.viewController setActiveScreenWithKey:@"TPGameScreen" withTransition:kFadeIn];
		return;	
	}
		
	[self.viewController setActiveScreenWithKey:@"HomeScreen" withTransition:kFadeIn];
	
}


-(void)drawView:(EAGLView *)view 
{
	[self drawView:view clear:YES];
}

-(void)drawView:(EAGLView *)view clear:(BOOL)clear;
{
	//qrGameState *gs = [qrGameState sharedqrGameState];
	vrTextBox *nb = (vrTextBox*)[self elementWithKey:@"NotificationBox"];
	nb.label = [_boardState statusString];
	
	if(clear){
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	}
	gluSetDefault2DStates();
	gluSetDefault2DProjection();
	
	Texture2D *t = [[vrTexturePool sharedvrTexturePool] objectForKey:@"Background.png"];
	[t drawInRect:ScaledBounds()];

	[_boardRenderer drawView:view];

	gluSetDefault2DStates();
	gluSetDefault2DProjection();
	
	for(vrUIElement *e in _elements)[e render];
	[_pickerView render];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	bool hit;
	for(UITouch *t in touches){
		hit = [_board checkDownTouch:t event:event withView:view];
		if(hit)break;
		
		CGPoint p = [t locationInView:view];
		float scale = ScreenScale();
		CGRect b = ScaledBounds();
		p.x = p.x *scale;
		p.y = p.y *scale;
		
		if(!_boardState.waitingForMove && !_boardState.gameOver){
			if(_boardState.pieceSelectMode){
				CGPoint mp = CGPointMake(p.x, b.size.height - p.y);
				[_pickerView checkMoveSelection:mp];				
			}
		}
		
	}
	[super touchesBegan:touches withEvent:event withView:view];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	bool hit;
	for(UITouch *t in touches){
		
		hit = [_board checkMoveTouch:t event:event withView:view];
		if(hit)break;
		
		CGPoint p = [t locationInView:view];
		float scale = ScreenScale();
		CGRect b = ScaledBounds();
		p.x = p.x *scale;
		p.y = p.y *scale;
		
		if(!_boardState.waitingForMove && !_boardState.gameOver){
			if(_boardState.pieceSelectMode){
				CGPoint mp = CGPointMake(p.x, b.size.height - p.y);
				[_pickerView checkMoveSelection:mp];				
			}
		}
	}
	[super touchesMoved:touches withEvent:event withView:view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	bool hit = NO;
	bool psHit = NO;
	bool sendLastMove = NO;
	
	UITouch *t = [touches anyObject];
	CGPoint p = [t locationInView:view];
	float scale = ScreenScale();
	CGRect b = ScaledBounds();
	p.x = p.x *scale;
	p.y = p.y *scale;
	
	for(UITouch *t in touches){
		hit = [_board checkUpTouch:t event:event withView:view];
		if(hit)break;
	}
	
	
	if(!_boardState.waitingForMove && !_boardState.gameOver){
		if(_boardState.pieceSelectMode){
			qrPiece *piece = nil;
			CGPoint mp = CGPointMake(p.x, b.size.height - p.y);
			
			piece = [self checkPieceSelection:mp];
			
			if(piece){
				_boardState.selectedPiece = piece;
				psHit = YES;
			}
		}
		
		
		if(_boardState.piecePlaceMode && hit && _board.touchPlace){
			int position;
			Vec3 result;
			hit = [_board boardPositionFromPoint:p position:&position result:&result];
			
			if(hit){
				if([_boardState isPositionFree:position]){
					[_boardState placePiece:_boardState.selectedPiece atPosition:position];
				}
				sendLastMove = _boardState.gameOver;
			}
		}
	}
	
	if(!hit && !psHit){
		CGPoint mp = CGPointMake(p.x, b.size.height*scale - p.y);
		[super touchesEnded:touches withEvent:event withView:view];
	}
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(psHit){
		[_boardState selectionLocked];
		if(gs.gameType == singlePlayer){
			[_boardState runAI];
		}
		if(gs.gameType == twoPlayerNetwork)[_boardState sendMove];
	}
	
	if(sendLastMove){
		if(gs.gameType == twoPlayerNetwork)[_boardState sendMove];
	}
}


@end
