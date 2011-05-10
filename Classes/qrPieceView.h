//
//  qrPieceView.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-25.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrOrthoView.h"
#import "qrPiece.h"
#import "glUtility.h"

@interface qrPieceView : qrOrthoView {
	float			_slRotation;
	
	qrPiece			*_piece;
	BOOL			_selected;
	BOOL			_lockedIn;
	float			_rotation;
	
	BOOL			_animating;
	int				_frameCount;
	float			_animationFrames;
	BOOL			_linear;
	CGRect			_targetBounds;
	CGRect			_currentBounds;
	CGRect			_deltaBounds;
}

@property (nonatomic, assign) qrPiece  *piece;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL lockedIn;

@property (nonatomic) CGRect targetBounds;
@property (nonatomic) CGRect currentBounds;
@property (nonatomic) BOOL animating;

-(void)animateToTarget:(CGRect)targetBounds frames:(int)frames linear:(BOOL)linear;
-(void)resetBounds;

-(void)render;	
-(void)renderPiece;

@end
