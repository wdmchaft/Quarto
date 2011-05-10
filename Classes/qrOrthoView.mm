//
//  qrOrthoView.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrOrthoView.h"
#import "glUtility.h"
#import "vrTexturePool.h"

@implementation qrOrthoView

@synthesize bounds = _bounds;
@synthesize backgroundTextureKey = _backgroundTextureKey;

-(BOOL)checkTouchPoint:(CGPoint)p
{
	return CGRectContainsPoint(_bounds, p);
}


-(void)setOrthoProjection
{
	
}


-(void)render
{
	vrTexturePool *tp = [vrTexturePool sharedvrTexturePool];
	if(_backgroundTextureKey){
		CGRect sb = ScaledBounds();
		CGRect maxB = CGRectMake(sb.origin.x,_bounds.origin.y,sb.size.width,_bounds.size.height);
		Texture2D *background = [tp objectForKey:_backgroundTextureKey];
		if(background)
			[background drawInRect:maxB depth:-10.0f];
	}
}


@end
