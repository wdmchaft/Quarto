//
//  QuartoAppDelegate.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright Barn*Star Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "qrAppController.h"
#import "qrGameState.h"

#define STATELOGGING 0

#if STATELOGGING
#define STATELOG(__LOGMSG__)				__LOGMSG__
#else
#define STATELOG(__LOGMSG__)				if(0)__LOGMSG__
#endif




@class EAGLView;

@interface QuartoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow			*window;
    EAGLView			*glView;
	qrAppController		*_appController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

