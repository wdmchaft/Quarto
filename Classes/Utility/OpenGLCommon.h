#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
//#import "glUtility.h"

#define DEG_TO_RAD(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RAD_TO_DEG(__ANGLE__)  ((__ANGLE__) * 180 / M_PI)

//#import "Vector.h"

static inline void iPadScaleRect(CGRect *r)
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	r->origin.x *= bounds.size.width/320.0f;
	r->origin.y *= bounds.size.height/480.0f;
	r->size.width *= bounds.size.width/320.0f;
	r->size.height *= bounds.size.height/480.0f;
}

#pragma mark -
#pragma mark OBJ Import Types
#pragma mark -

typedef struct {
	GLuint  stride;
	GLuint  vertOffset;
	GLuint  textOffset;
	GLuint  normOffset;
} glVBOParam;

typedef struct {
	GLfloat red;
	GLfloat green;
	GLfloat blue;
	GLfloat alpha;
} ColorRGBA;

typedef struct {
	GLfloat red;
	GLfloat green;
	GLfloat blue;
} ColorRGB;

typedef struct {
	GLuint count; // always 1
	GLfloat u;
} TextureCoord1D;

typedef struct {
	GLuint count; // always 2
	GLfloat u;
	GLfloat v;
} TextureCoord2D;

typedef struct {
	GLuint count; // always 3
	GLfloat u;
	GLfloat v;
	GLfloat w;
} TextureCoord3D;

typedef ColorRGBA Color3D;


static inline Color3D Color3DMake(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha)
{
    Color3D ret;
	ret.red = inRed;
	ret.green = inGreen;
	ret.blue = inBlue;
	ret.alpha = inAlpha;
    return ret;
}


#pragma mark -
#pragma mark Vertex3D
#pragma mark -

typedef struct {
	GLfloat	x;
	GLfloat y;
	GLfloat z;
} Vertex3D;

//typedef VECTOR3 Vertex3D;

typedef struct {
	GLfloat u;
	GLfloat v;
}UVVertex2D;

typedef struct {
	GLfloat x;
	GLfloat y;
} Vertex2D;

static inline Vertex3D Vertex3DMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
	Vertex3D ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}

static inline UVVertex2D UVVertex2DMake(CGFloat inU, CGFloat inV)
{
	UVVertex2D ret;
	ret.u = inU;
	ret.v = inV;
	return ret;
}

static inline Vertex2D Vertex2DMake(CGFloat inX, CGFloat inY)
{
	Vertex2D ret;
	ret.x = inX;
	ret.y = inY;
	return ret;
}

#pragma mark -
#pragma mark Vector3D
#pragma mark -
typedef Vertex3D Vector3D;
typedef Vertex2D Vector2D;

#define Vector3DMake(x,y,z) (Vector3D)Vertex3DMake(x, y, z)
#define Vector2DMake(x,y) (Vector2D)Vertex2DMake(x,y)

static inline GLfloat Vector3DMagnitude(Vector3D vector)
{
	return sqrtf((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z)); 
}

static inline GLfloat Vector2DMagnitude(Vector2D vector)
{
	return sqrtf((vector.x * vector.x) + (vector.y * vector.y)); 
}

static inline void Vector3DNormalize(Vector3D *vector)
{
	GLfloat vecMag = Vector3DMagnitude(*vector);
	if ( vecMag == 0.0f )
	{
		vector->x = 0.0f;
		vector->y = 0.0f;
		vector->z = 0.0f;
	}
	vector->x /= vecMag;
	vector->y /= vecMag;
	vector->z /= vecMag;
}


static inline GLfloat Vector3DDotProduct(Vector3D vector1, Vector3D vector2)
{		
	return vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z;
	
}

static inline Vector3D Vector3DCrossProduct(Vector3D vector1, Vector3D vector2)
{
	Vector3D ret;
	ret.x = (vector1.y * vector2.z) - (vector1.z * vector2.y);
	ret.y = (vector1.z * vector2.x) - (vector1.x * vector2.z);
	ret.z = (vector1.x * vector2.y) - (vector1.y * vector2.x);
	return ret;
}

static inline Vector3D Vector3DFromAngle(GLfloat angle)
{
	Vector3D ret;
	ret.y = sinf(angle);
	ret.x = cosf(angle);
	ret.z = 0;
	return ret;
}

static inline Vector3D Vector3DScale(Vector3D vector1, GLfloat factor)
{
	Vector3D ret;
	ret.x = factor*vector1.x;
	ret.y = factor*vector1.y;
	ret.z = factor*vector1.z;
	return ret;
}


static inline Vector3D Vector3DMakeWithStartAndEndPoints(Vertex3D start, Vertex3D end)
{
	Vector3D ret;
	ret.x = end.x - start.x;
	ret.y = end.y - start.y;
	ret.z = end.z - start.z;
	Vector3DNormalize(&ret);
	return ret;
}

static inline Vector3D Vector3DAdd(Vector3D vector1, Vector3D vector2)
{
	Vector3D ret;
	ret.x = vector1.x + vector2.x;
	ret.y = vector1.y + vector2.y;
	ret.z = vector1.z + vector2.z;
	return ret;
}


static inline void Vector3DFlip (Vector3D *vector)
{
	vector->x = -vector->x;
	vector->y = -vector->y;
	vector->z = -vector->z;
}


#pragma mark -
#pragma mark Rotation3D
#pragma mark -
// A Rotation3D is just a Vertex3D used to store three angles (pitch, yaw, roll) instead of cartesian coordinates. 
// For simplicity, we just reuse the Vertex3D, even though the member names should probably be either xRot, yRot, 
// and zRot, or else pitch, yaw, roll. 
typedef Vertex3D Rotation3D;
#define Rotation3DMake(x,y,z) (Rotation3D)Vertex3DMake(x, y, z)
#pragma mark -
#pragma mark Face3D
#pragma mark -
// Face3D is used to hold three integers which will be integer index values to another array
typedef struct {
	GLushort	v1;
	GLushort	v2;
	GLushort	v3;
} Face3D;


static inline Face3D Face3DMake(int v1, int v2, int v3)
{
	Face3D ret;
	ret.v1 = v1;
	ret.v2 = v2;
	ret.v3 = v3;
	return ret;
}


#pragma mark -
#pragma mark Triangle3D
#pragma mark -
typedef struct {
	Vertex3D v1;
	Vertex3D v2;
	Vertex3D v3;
} Triangle3D;


static inline Triangle3D Triangle3DMake(Vertex3D inV1, Vertex3D inV2, Vertex3D inV3)
{
	Triangle3D ret;
	ret.v1 = inV1;
	ret.v2 = inV2;
	ret.v3 = inV3;
	return ret;
}


static inline Vector3D Triangle3DCalculateSurfaceNormal(Triangle3D triangle)
{
	Vector3D u = Vector3DMakeWithStartAndEndPoints(triangle.v2, triangle.v1);
	Vector3D v = Vector3DMakeWithStartAndEndPoints(triangle.v3, triangle.v1);
	
	Vector3D ret;
	ret.x = (u.y * v.z) - (u.z * v.y);
	ret.y = (u.z * v.x) - (u.x * v.z);
	ret.z = (u.x * v.y) - (u.y * v.x);
	return ret;
}


