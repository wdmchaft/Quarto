//
//  vrPlaneCNode.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-18.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "vrCollisionNode.h"
#import "vrMath.h"
#import "OpenGLCommon.h"

@interface vrPlaneCNode : vrCollisionNode <NSCopying> {
	Vec3			_staticVerts[4];
	Vec3			_v[4];
	Color3D			debugCol;
}

+(vrPlaneCNode*)nodeWithDictionary:(NSDictionary *)d parent:(id)parent;
-(void)setPoints:(Vec3*)points;

@end
