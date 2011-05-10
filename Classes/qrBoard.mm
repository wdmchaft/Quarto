//
//  qrBoard.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrBoard.h"
#import "vrModelPool.h"
#import "glUtility.h"
#import "qrGeometryGlobals.h"

@implementation qrBoard

@synthesize zRotation = _zRotation;
@synthesize touchPlace = _touchPlace;

-(id)init
{
	self = [super init];
	if(self){
		[self loadModel];
		[self setup];
		_tp.touch = nil;
		_zRotation = 3;
	}
	return self;
}

-(void)dealloc
{
	[_model release];
	[_collisionNodes release];
	[super dealloc];
}

-(void)loadModel
{
	vrModelPool *modelPool = [vrModelPool sharedvrModelPool];
	_model = [[modelPool objectForKey:@"board"] retain];
	
	if(!_model)NSLog(@"Error Loading Board Model...");
}


-(void)setup
{
	if(_collisionNodes){
		[_collisionNodes release];
		_collisionNodes = nil;
	}
	
	_collisionNodes = [[NSMutableArray alloc] initWithCapacity:16];
	
	float x=-8,y=-8;
	float dx =4, dy=4;
	
		
	for(int i=0;i<16;i++){
		NSMutableDictionary *cNodeDef = [[NSMutableDictionary alloc] initWithCapacity:3];
		NSString *v1 = [NSString stringWithFormat:@"%f,%f,0",x,y+dy];
		NSString *v2 = [NSString stringWithFormat:@"%f,%f,0",x,y];
		NSString *v3 = [NSString stringWithFormat:@"%f,%f,0",x+dx,y+dy];
		NSString *v4 = [NSString stringWithFormat:@"%f,%f,0",x+dx,y];
		
		//NSLog(@"Creating cNode v1(%@) v2(%@) v3(%@) v4(%@)",v1,v2,v3,v4);
		
		NSArray *verts = [NSArray arrayWithObjects:v1,v2,v3,v4,nil];
		[cNodeDef setObject:verts forKey:@"vertices"];
		
		NSNumber *index = [NSNumber numberWithInt:i];
		[cNodeDef setObject:index forKey:@"index"];
		
		vrPlaneCNode *cNode = [vrPlaneCNode nodeWithDictionary:cNodeDef parent:self];
		[_collisionNodes addObject:cNode];
		[cNodeDef release];
		
		x+=dx;
		if(x>4){
			x=-8;y+=dy;
		}
	}
}


-(BOOL)boardPositionFromPoint:(CGPoint)point position:(int*)pos result:(Vec3*)result
{
	Vec3 start, end;
	BOOL hit = NO;
	
	//[self calRay2:point start:&start dir:&dir];
	[self calculateRayFromScreenPos:point start:&start end:&end];

	//[self calRay3:point start:&start dir:&dir];
	
	//NSLog(@"Start (%f,%f,%f)",start.x,start.y,start.z);
	//NSLog(@"End   (%f,%f,%f)",dir.x,dir.y,dir.z);

	_rayStart = start;
	_rayEnd = end;
	
	
	for(vrPlaneCNode *c in _collisionNodes){
		hit = [c lineCollision:start end:end result:result];
		if(hit){
			*pos = c.index;
			break;
		}
	}
	return hit;
}



-(void)debugDrawRay
{
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER,0);
	Color3D c = Color3DMake(1,0,0,1);
	gluDrawSegment(&_rayStart, &_rayEnd, &c, 3.0f);
}

-(void)calculateRayFromScreenPos:(CGPoint)winPos start:(Vec3*)start end:(Vec3*)end
{
	// I am doing this once at the beginning when I set the perspective view
	qrGeometryGlobals *gg = [qrGeometryGlobals sharedqrGeometryGlobals];
	MATRIX modelView = [gg modelViewMatrix];
	MATRIX projection = [gg projectionMatrix];
	GLint *viewPort = [gg viewPort];
	
	Vec3 win;
	
	win.y = ((float)viewPort[3] - winPos.y);
	win.x = (winPos.x);
	win.z = 0;
	gluUnProject( win, &modelView, &projection, viewPort, start);
	
	win.y = ((float)viewPort[3] - winPos.y);
	win.x = (winPos.x);
	win.z = 1;
	gluUnProject( win, &modelView, &projection, viewPort, end);
	
}

-(vr3DModel *)boardModel
{
	return _model;
}


-(bool)checkDownTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	//NSLog(@"Board Touch Check...");
	if(_tp.touch)return false;
	CGPoint p = [touch locationInView:view];
	CGRect b = ScaledBounds();
	float s = ScreenScale();
	p.x = p.x *s;
	p.y = p.y *s;
	/*
	if([[qrGameState sharedqrGameState] screenFlipped]){
		p.x = b.size.width-p.x;
		p.y = b.size.height-p.y;
	}*/
	//p.y = b.size.height - p.y;
	
	Vec3 result; int position;
	bool hit = [self boardPositionFromPoint:p position:&position result:&result];
	
	if(hit && !_tp.touch){
		//NSLog(@"Detected Board Touch...");
		_tp.startLocation = p;
		_tp.lastLocation = p;
		_tp.length = 0;
		_tp.rotationOrigin = _zRotation;
		_tp.timeStamp = [touch timestamp];
		_tp.spin = NO;
		_tp.touch = touch;
		_tp.spin = YES;
		_touchPlace = YES;
		
		CGPoint cv = CGPointMake(b.size.width/2 - p.x, b.size.height/2 - p.y);
		_tp.startAngle =  atan2(cv.y,cv.x);
	}
	
	return hit;
}


-(bool)checkMoveTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	//NSLog(@"Check: Board Touch Moved...");
	if(touch == _tp.touch){
		//NSLog(@"Board Touch Moved...");
		CGPoint p = [touch locationInView:view];
		CGRect b = ScaledBounds();
		float s = ScreenScale();
		p.x = p.x *s;
		p.y = p.y *s;
		
		/*
		if([[qrGameState sharedqrGameState] screenFlipped]){
			p.x = b.size.width-p.x;
			p.y = b.size.height-p.y;
		}*/
		
		//p.y = b.size.height - p.y;
		Vec3 p1 = Vec3(p.x,p.y,0);
		Vec3 p2 = Vec3(_tp.lastLocation.x, _tp.lastLocation.y,0);
		Vec3 sw = p1-p2;
		
		float len = sw.length();
		if(len > 5)_touchPlace = NO;
		_tp.lastLocation = p;
		_tp.length = len;
		
		CGPoint cv = CGPointMake(b.size.width/2 - p.x, b.size.height/2 - p.y);
		
		float ca = RAD_TO_DEG(atan2(cv.y,cv.x) - _tp.startAngle);
		float da = _tp.lastAngle - ca;
		_tp.lastAngle = ca;
		
		if(_tp.spin){
			if(fabs(da)<10){
				_zRotation = _zRotation + da;
			}
		}
		return true;
	}
	return false;
}


-(bool)checkUpTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view
{
	if(touch == _tp.touch){
		//NSLog(@"Board Touch Up...");
		_tp.touch = nil;
		return true;
	}
	return false;
}


/*
-(void)calRay3:(CGPoint)winPos start:(Vec3*)start dir:(Vec3*)dir
{
	float dx,dy;
	MATRIX invMatrix,viewMatrix;
	
	CGRect bounds = [[UIScreen mainScreen] bounds];
	
	qrGeometryGlobals *gg = [qrGeometryGlobals sharedqrGeometryGlobals];
	MATRIX modelView = [gg modelViewMatrix];
	MATRIX projection = [gg projectionMatrix];
	GLint *viewPort = [gg viewPort];
	
	float aspect = bounds.size.width/bounds.size.height;
	
	dx=tanf(DEG_TO_RAD(FIELD_OF_VIEW)*0.5f)*(winPos.x/(bounds.size.width/2)-1.0f)/aspect;
	dy=tanf(DEG_TO_RAD(FIELD_OF_VIEW)*0.5f)*(1.0f-winPos.y/(bounds.size.height/2));
	
	MATRIX m;
	MatrixMultiply(m, modelView, projection);
	
	MatrixInverse(invMatrix, m);
	Vec3 p1 = Vec3(dx*Z_NEAR,dy*Z_NEAR,Z_NEAR);
	Vec3 p2 = Vec3(dx*Z_FAR,dy*Z_FAR,Z_FAR);
	
	Vec3 end;
	
	MatrixVec3Multiply(*start, p1, invMatrix);
	MatrixVec3Multiply(end, p2, invMatrix);
	
	*dir = (end - (*start)).normalize();
}

-(void)calRay2:(CGPoint)winPos start:(Vec3*)start dir:(Vec3*)dir
{
	
	qrGeometryGlobals *gg = [qrGeometryGlobals sharedqrGeometryGlobals];
	MATRIX modelView = [gg modelViewMatrix];
	MATRIX projection = [gg projectionMatrix];
	GLint *viewPort = [gg viewPort];
	
	CGRect bounds = [[UIScreen mainScreen] bounds];
	
	Vec3 v;
	v.x =  ( ( ( 2.0f * winPos.x ) / bounds.size.width  ) - 1 ) / projection.f[_11];
	v.y = -( ( ( 2.0f * winPos.y ) / bounds.size.height ) - 1 ) / projection.f[_22];
	v.z =  1.0f;

	Vec3 rayOrigin,rayDir;
	
	MATRIX m;
	MatrixInverse(m,modelView);
	
	
	// Transform the screen space pick ray into 3D space
	start->x  = m.f[_11] * v.x + m.f[_21]*v.y + m.f[_31]*v.z;
	start->y  = m.f[_12] * v.x + m.f[_22]*v.y + m.f[_32]*v.z;
	start->z  = m.f[_13] * v.x + m.f[_23]*v.y + m.f[_33]*v.z;
	rayDir.x = m.f[_41];
	rayDir.y = m.f[_42];
	rayDir.z = m.f[_43];	
	
	*start = *start + rayDir;
}
*/
@end
