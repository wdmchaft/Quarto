//
//  vrCollisionNode.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-16.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrMath.h"

typedef enum {
	kSolid = 1,
	kPassable
}vrCollisionNodeType;

//Abstract base class for a collision node.
//To be inherited by the different types of nodes (AABB, Sphere, Plane)

@interface vrCollisionNode : NSObject {
	id						_parent;
	vrCollisionNodeType		_type;		
	bool					_damagesActor;	//Whether hitting the node damages the actor
	Vec3					_centroid;
	
	int						_index;
}

@property (nonatomic, assign) id parent;
@property (nonatomic) vrCollisionNodeType type;
@property (nonatomic) bool damagesActor;
@property (nonatomic) Vec3 centroid;
@property (nonatomic) int index;

-(id)initWithParent:(id)parent type:(vrCollisionNodeType)type;

//To be implemented by sub-classes - if applicable

-(void)translate:(Vec3)t zRotation:(float)z;

-(bool)pointCollision:(Vec3)p;
-(bool)lineCollision:(Vec3)start end:(Vec3)end result:(Vec3*)result;
-(bool)rayCollision:(Vec3)p direction:(Vec3)d result:(Vec3*)result;
-(bool)sphereCollision:(Vec3)center radius:(float)radius;
-(bool)sphereCollision:(Vec3)center radius2:(float)radius2;

-(void)debugDraw;

@end
