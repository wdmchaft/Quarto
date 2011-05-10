//
//  qrOrthoView.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"

@interface qrOrthoView : NSObject {
	CGRect		_bounds;
	NSString	*_backgroundTextureKey;
}

@property (nonatomic) CGRect bounds;
@property (nonatomic,retain) NSString *backgroundTextureKey;

-(BOOL)checkTouchPoint:(CGPoint)p;
-(void)setOrthoProjection;
-(void)render;

@end
