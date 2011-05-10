//
//  qrBoard.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vr3DModel.h"
#import "vrPlaneCNode.h"

typedef struct {
	CGPoint		startLocation;
	CGPoint		lastLocation;
	float		length;
	float		rotationOrigin;
	NSTimeInterval timeStamp;
	BOOL		spin;
	UITouch		*touch;
	float		startAngle;
	float		lastAngle;
}TouchProperties;

@interface qrBoard : NSObject {
	NSMutableArray	*_collisionNodes;
	vr3DModel		*_model;
	
	Vec3			_rayStart;
	Vec3			_rayEnd;
	
	float			_zRotation;
	bool			_touchPlace;
	
	TouchProperties	_tp;

}

@property (nonatomic, readonly) float zRotation;
@property (nonatomic, readonly) bool touchPlace;

-(id)init;

-(void)loadModel;
-(void)setup;

-(BOOL)boardPositionFromPoint:(CGPoint)point position:(int*)pos result:(Vec3*)result;
-(void)calculateRayFromScreenPos:(CGPoint)winPos start:(Vec3*)start end:(Vec3*)end;

-(void)debugDrawRay;

-(bool)checkDownTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;
-(bool)checkMoveTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;
-(bool)checkUpTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;


-(vr3DModel *)boardModel;

@end
