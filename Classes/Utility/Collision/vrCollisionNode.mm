//
//  vrCollisionNode.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-16.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "vrCollisionNode.h"


@implementation vrCollisionNode

@synthesize parent = _parent;
@synthesize type = _type;
@synthesize damagesActor = _damagesActor;
@synthesize centroid = _centroid;
@synthesize index = _index;

-(id)initWithParent:(id)parent type:(vrCollisionNodeType)type;
{
	self = [super init];
	if(self){
		self.parent = parent;
		_type = type;
	}
	return self;
}

-(void)translate:(Vec3)t zRotation:(float)z
{
	NSLog(@"Error: Translation Not Implemented For %@",[self class]);
}


//To be implemented by sub-classes
-(bool)pointCollision:(Vec3)p
{
	NSLog(@"Error: Point Collision Not Defined for %@",[self class]);
	return false;
}

-(bool)lineCollision:(Vec3)start end:(Vec3)end result:(Vec3*)result
{
	NSLog(@"Error: Line Collision Not Defined for %@",[self class]);
	return false;
}

-(bool)rayCollision:(Vec3)p direction:(Vec3)d result:(Vec3*)result
{
	NSLog(@"Error: Ray Collision Not Defined for %@",[self class]);
	return false;
}

-(bool)sphereCollision:(Vec3)center radius:(float)radius{
	NSLog(@"Error: Sphere Collision (rad) Not Defined for %@",[self class]);
	return false;
}	

-(bool)sphereCollision:(Vec3)center radius2:(float)radius2
{
	NSLog(@"Error: Sphere Collision (rad2) Not Defined for %@",[self class]);
	return false;
}

-(void)debugDraw
{
}

@end
