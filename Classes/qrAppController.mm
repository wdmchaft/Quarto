//
//  qrAppController.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-24.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrAppController.h"
#import "vrConstants.h"
#import "glTextManager.h"
#import "qrGameState.h"
#import "vrAudioManager.h"
#import "UIDevice+machine.h"

@implementation qrAppController

-(id)initWithView:(EAGLView *)view
{
	self = [super init];
	if(self){
		_view = [view retain];
		[_view setAnimationFrameInterval:3];
		
		_viewController = [[qrViewController alloc] initWithGLView:view];
		_mpSessionController = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
		
		[self loadTextures];
		[self loadModels];
		[self createBoard];

		[_view setTouchDelegate:self];
		[_view setDelegate:self];
		
		_gameScreen = [[qrGameScreen alloc] initWithController:_viewController];
		[_gameScreen setBoardState:_boardState];
		[_viewController setGameScreen:_gameScreen];
		
		DeviceType devType = [[UIDevice currentDevice] deviceType];
		NSString *uiLayoutFile = @"UILayout_iphone";
		if(devType == kiPadDevice)uiLayoutFile = @"UILayout_ipad";
		
		LOG(NSLog(@"Using %@",uiLayoutFile));
		
		NSString *uiLayoutPath = [[NSBundle mainBundle] pathForResource:uiLayoutFile ofType:@"plist"];
		NSDictionary *uiLayout = [[NSDictionary dictionaryWithContentsOfFile:uiLayoutPath] retain];
		[_viewController loadUIScreens:uiLayout];
		[uiLayout release];
		
		id plh = [_viewController screenForKey:@"TPGameScreen"];
		if(!plh)NSLog(@"Error: Could not find peer list handler");
		_mpSessionController.peerListHandler = plh;
		
		//Initialize the font engine
		[glTextManager sharedTextManager];
		qrGameState *gs = [qrGameState sharedqrGameState];
		[gs loadState];
		gs.gameType = singlePlayer;
		
		[_viewController setActiveScreenWithKey:@"HomeScreen"];
		
		_mpSessionController.dataDelegate = _boardState;
		[_mpSessionController startPeer];
		
		_boardState.multiPlayerSessionController = _mpSessionController;
		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 2.0f)];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		
		vrAudioManager *am = [vrAudioManager sharedvrAudioManager];
		[am loadUIEffectList:@"SoundEffects"];
	}
	return self;
}

-(void)dealloc
{
	[_viewController release];
	[_mpSessionController stopPeer];
	[_mpSessionController release];
	[_boardState release];
	[super dealloc];
}

-(void)createBoard
{
	_boardState = [[qrBoardState alloc] init];
	_board = [_boardState board];
}


-(void)loadTextures
{
	_textureController = [[qrGameTextureController alloc] init];
	
	DeviceGen g = [[UIDevice currentDevice] deviceGeneration];
	
	NSString *sharedTextures;
	NSString *UITextures;
	
	if(g==kFirstGen || g==kSecondGen){
		sharedTextures = @"SharedTextures_small";
		UITextures = @"UITextures_small";
	}else{
		sharedTextures = @"SharedTextures";
		UITextures = @"UITextures";
	}
	
	[_textureController loadTexturesFromPlist:sharedTextures];
	[_textureController loadTexturesFromPlist:UITextures];
}

-(void)freeAllTextures
{
	//[_mpSessionController stopPeer];
	[_textureController freeAllTextureMemory];
}


-(void)reloadTextures
{
	//[_mpSessionController startPeer];
	[_textureController restoreTextures];
}

-(void)loadModels
{
	NSString *zero = [[NSString alloc] initWithString:@"0"];
	NSString *one  = [[NSString alloc] initWithString:@"1"];
	
	vrModelPool *modelPool = [vrModelPool sharedvrModelPool];
	
	//Load Board
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"obj"];
	vr3DModel *model = [[vr3DModel alloc] initWithPath:path modelKey:@"board"];
	[modelPool addModel:model withKey:@"board"];
	[model release];
	
	//Load Pieces
	
	for(unsigned char i=0;i<16;i++){
		NSMutableString *fName = [[NSMutableString alloc] init];
		[fName appendFormat:@"p"];
		for (unsigned char z = 8; z > 0; z >>= 1)
			(i & z)	? [fName appendString:one] : [fName appendString:zero];
				
		//NSLog(@"Loading Obj File: %@",fName);
		
		path = [[NSBundle mainBundle] pathForResource:fName ofType:@"obj"];
		model = [[vr3DModel alloc] initWithPath:path modelKey:fName];
		
		[modelPool addModel:model withKey:fName];
		
		[model release];
		[fName release];
	}
	[one release];
	[zero release];
}

-(void)fadeIn{
	[_viewController fadeInActiveScreen];
}

-(void)forceMainScreen
{
	[_viewController setActiveScreenWithKey:@"HomeScreen"];
}

-(void)clearView{
	[_viewController clearView];
}

-(void)drawView:(EAGLView*)view
{
	[_viewController drawView:view];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	[_viewController touchesBegan:touches withEvent:event withView:view];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	[_viewController touchesMoved:touches withEvent:event withView:view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	[_viewController touchesEnded:touches withEvent:event withView:view];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	qrGameState *gs = [qrGameState sharedqrGameState];
	
#if TARGET_IPHONE_SIMULATOR
	gs.screenFlipped = false;
#else
	float x = acceleration.x;
	if((x <-.4) && !_flip){
		gs.screenFlipped = true;
		_flip = true;
		//[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
	}
	else if(x>.4 && _flip){		
		gs.screenFlipped = false;
		_flip = false;
		//[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeLeft];
	}
#endif
}

@end
