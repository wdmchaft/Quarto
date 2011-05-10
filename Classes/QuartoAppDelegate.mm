//
//  QuartoAppDelegate.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright Barn*Star Studios 2010. All rights reserved.
//

#import "QuartoAppDelegate.h"
#import "EAGLView.h"

@implementation QuartoAppDelegate

@synthesize window;
@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //_viewController = [[qrViewController alloc] initWithView:glView];
	qrGameState *gs = [qrGameState sharedqrGameState];
	[gs loadState];
	
	
	_appController  = [[qrAppController alloc] initWithView:glView];
	[_appController fadeIn];
	
	[glView startAnimation];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    STATELOG(NSLog(@"Calling Resign"));
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.gameType == twoPlayerNetwork)[_appController forceMainScreen];
	[glView stopAnimation];
	
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	[mps stopPeer];
	[glView destroyFramebuffer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	STATELOG(NSLog(@"Calling Become Active"));
	[_appController reloadTextures];
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	[mps startPeer];
	[_appController fadeIn];
	[glView createFrameBuffer];
	[glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	qrMultiPlayerSessonController *mps = [qrMultiPlayerSessonController sharedqrMultiPlayerSessonController];
	[mps stopPeer];
	qrGameState *gs = [qrGameState sharedqrGameState];
	[gs saveState];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
	STATELOG(NSLog(@"Calling Enter Foreground"));
}

-(void)applicationWillEnterBackground:(UIApplication *)application
{
	STATELOG(NSLog(@"Calling Enter Background"));
}


- (void)dealloc
{
    [_appController release];
	[window release];
    [glView release];
	
    [super dealloc];
}

@end
