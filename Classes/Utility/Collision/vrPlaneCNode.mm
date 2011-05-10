//
//  vrLinePlaneCollision.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 10-03-18.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "vrPlaneCNode.h"
#import "NSString+vectorParse.h"


@implementation vrPlaneCNode


/**** 
 Compute the intersection of a ray and a triangle
 p			: ray start
 d			: ray direction (normalized)
 v0,v1,v2	: triangle vertices
 *result	: intersection 

 Returns	: true if intersection found.
****/

static bool rayIntersectsTriangle(Vec3 p, Vec3 d, Vec3 v0, Vec3 v1, Vec3 v2, Vec3 *result)
{
	Vec3 e1,e2,h,s,q;
	
	float a,f,u,v;
	
	e1 = v1 - v0;
	e2 = v2 - v0;	
	
	h = d.cross(e2);
	a = e1.dot(h);
	
	if (a > -0.00001 && a < 0.00001)
		return(false);
	
	f = 1.0f/a;
	s= p - v0;
	
	u = s.dot(h) * f;
	
	if (u < 0.0 || u > 1.0)
		return(false);
	
	q = s.cross(e1);
	v =  d.dot(q) * f;
	
	if (v < 0.0 || u + v > 1.0)
		return(false);
	// at this stage we can compute t to find out where 
	// the intersection point is on the line
	float t = e2.dot(q)*f;
	if (t > 0.00001){ // ray intersection
		*result = p + d*t;
		return(true);
	}else{
		// this means that there is a line intersection  
		// but not a ray intersection
		return (false);
	}
}

-(id)copyWithZone:(NSZone*)zone
{
	vrPlaneCNode *ret = [[vrPlaneCNode alloc] initWithParent:_parent type:_type];
	
	if(ret){
		ret.damagesActor = _damagesActor;
		[ret setPoints:_staticVerts];
	}
	return ret;
}

+(vrPlaneCNode*)nodeWithDictionary:(NSDictionary *)d parent:(id)parent
{
	Vec3 v[4];
	NSString *type= nil;
	bool damagesActor = true;;
	vrCollisionNodeType t;
	int index;
	
	for(NSString *key in d){
		if([key isEqualToString:@"damagesActor"]){
			damagesActor = [[d objectForKey:key] boolValue];
		}
		else if([key isEqualToString:@"type"]){
			type = [NSString stringWithString:[d objectForKey:key]];
		}
		else if([key isEqualToString:@"index"]){
			index = [[d objectForKey:@"index"] intValue];
		}
		else if([key isEqualToString:@"vertices"]){
			int index = 0;
			for(NSString *vert in [d objectForKey:key]){
				Vector3D vt = [vert vector3DFromCDS];
				if(index<4)v[index] = Vec3(vt);
				else NSLog(@"ERROR: planeCNode - too many verts (%d)",index);
				index++;
			}
		}
	}
	
	if(type){
		if([type isEqualToString:@"passable"])t = kPassable;
		else if([type isEqualToString:@"solid"])t = kSolid;
	}else {
		//NSLog(@"WARNING: planeNode - no type specified - setting to passable");
		t = kPassable;
	}
	
	vrPlaneCNode *ret = [[[vrPlaneCNode alloc] initWithParent:parent type:t] autorelease];
	[ret setPoints:v];
	ret.damagesActor = damagesActor;
	ret.index = index;
		
	return ret;
}

-(void)setPoints:(Vec3*)points
{
	memcpy(_v,points,4*sizeof(Vec3));
	memcpy(_staticVerts,points,4*sizeof(Vec3));
	
	_centroid = Vec3(0,0,0);
	for(int i=0;i<4;i++){
		_centroid += points[i];
	}
	_centroid = _centroid * .25;
	
}

-(void)translate:(Vec3)t zRotation:(float)z
{
	//Vec3 v[4];
	MATRIX mtrans;
	MATRIX mrot;
	MATRIX mtr;
	
	MatrixTranslation(mtrans, t.x, t.y, t.z);
	MatrixRotationZ(mrot,DEG_TO_RAD(-z));

	MatrixMultiply(mtr, mrot, mtrans);
	
	Vec3 cTemp = _centroid;
	TransTransformArray(_v, _staticVerts, 4, &mtr, 1);
	TransTransformArray(&_centroid, &cTemp, 1, &mtr, 1);
}

-(bool)lineCollision:(Vec3)start end:(Vec3)end result:(Vec3*)result
{
	bool c=false;
	
	Vec3 d = (end-start).normalize();
	
	//Test Triangle 1
	c = rayIntersectsTriangle(start, d, _v[0], _v[1], _v[2], result);
	//Test Triangle 2
	if(!c)c = rayIntersectsTriangle(start, d, _v[1], _v[2], _v[3], result);
	
	//No ray intersection?  Return False
	if(!c)return false;
	
	//Ray intersects... Test if the intersection point is before the end point
	float lineLen2 = (end-start).length2();
	float resLen2 =  (*result-start).length2();
		
	if(resLen2 < lineLen2)return true;
	return false;
	
}

-(bool)rayCollision:(Vec3)p direction:(Vec3)d result:(Vec3*)result
{
	bool c=false;
	
	//Test Triangle 1
	c = rayIntersectsTriangle(p, d, _v[0], _v[1], _v[2], result);
	//Test Triangle 2
	if(!c)c = rayIntersectsTriangle(p, d, _v[1], _v[2], _v[3], result);
	
	return c;
}

-(bool)sphereCollision:(Vec3)center radius:(float)radius
{
	return [self sphereCollision:center radius2:radius*radius];
}

-(bool)sphereCollision:(Vec3)center radius2:(float)radius2
{
	//Simple centroid distance check...  Fugly
	float d2 = (center - _centroid).length2();
	if(d2 < radius2)return true;
	
	//Check all 4 points
	for(int i=0;i<4;i++){
		d2 = (center - _v[i]).length2();
		if(d2<radius2)return true;
	}
	return false;
	
}


-(void)debugDraw
{
	glColor4f(1,0,0,1);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glDisableClientState(GL_NORMAL_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, _v);
	glDrawArrays(GL_LINE_LOOP,0,4);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	glColor4f(1,1,1,1);
}

@end
