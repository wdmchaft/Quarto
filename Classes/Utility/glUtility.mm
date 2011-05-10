/*
 *  glUtility.c
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 07/03/09.
 *  Copyright 2009 Barn*Star Studios. All rights reserved.
 *
 */

#include "glUtility.h"




bool gluLoadTexture(NSString *filename, GLuint texture, GLenum min_filter)
{
	CGImageRef		textureImage;
	CGContextRef	textureContext;
	GLubyte			*textureData;
	size_t			width, height;
	
	textureImage	= [UIImage imageNamed:filename].CGImage;
	width			= CGImageGetWidth(textureImage);
	height			= CGImageGetHeight(textureImage);
	
	if(textureImage)
	{
		textureData = (GLubyte *) malloc(width * height * 4);
		textureContext = CGBitmapContextCreate(textureData, width, height, 8, width * 4, CGImageGetColorSpace(textureImage), kCGImageAlphaPremultipliedLast);
		CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), textureImage);
		CGContextRelease(textureContext);
		
		glBindTexture(GL_TEXTURE_2D, texture);
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, min_filter); 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		free(textureData);
		LOG(NSLog(@"Texture %d loaded successfully",texture));
		return true;
	}	
	NSLog(@"Texture Load %d failed...",texture);
	return false;
}


void gluDrawSegment(Vec3 *v1, Vec3 *v2, Color3D *color, GLfloat width)
{

	GLfloat seg[] = {v1->x,v1->y,v1->z,v2->x,v2->y,v2->z};
	glDisable(GL_TEXTURE_2D);
	glColor4f(color->red, color->green, color->blue, color->alpha);
	glVertexPointer(3, GL_FLOAT, 0, seg);
	glDrawArrays(GL_LINES, 0, 2); 
}

void gluDrawRect(CGRect r, GLfloat depth, Color3D *color, GLfloat width)
{
	GLfloat seg[] = {
		r.origin.x,r.origin.y, depth,
		r.origin.x+r.size.width,r.origin.y,depth,
		r.origin.x+r.size.width,r.origin.y+r.size.height,depth,
		r.origin.x,r.origin.y+r.size.height,depth
	};
	glDisable(GL_TEXTURE_2D);
	glColor4f(color->red, color->green, color->blue, color->alpha);
	glLineWidth(width);
	glVertexPointer(3, GL_FLOAT, 0, seg);
	glDrawArrays(GL_LINE_LOOP, 0, 4); 
	glEnable(GL_TEXTURE_2D);
}

void gluLookAt(GLfloat eyex,    GLfloat eyey,    GLfloat eyez,
			   GLfloat centerx, GLfloat centery, GLfloat centerz,
			   GLfloat upx,     GLfloat upy,     GLfloat upz     )
{
	GLfloat m[16];
	GLfloat x[3], y[3], z[3];
	GLfloat mag;
	
	/* Make rotation matrix */
	
	/* Z vector */
	z[0] = eyex - centerx;
	z[1] = eyey - centery;
	z[2] = eyez - centerz;
	mag = sqrt(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
	if (mag) {			/* mpichler, 19950515 */
		z[0] /= mag;
		z[1] /= mag;
		z[2] /= mag;
	}
	
	/* Y vector */
	y[0] = upx;
	y[1] = upy;
	y[2] = upz;
	
	/* X vector = Y cross Z */
	x[0] = y[1] * z[2] - y[2] * z[1];
	x[1] = -y[0] * z[2] + y[2] * z[0];
	x[2] = y[0] * z[1] - y[1] * z[0];
	
	/* Recompute Y = Z cross X */
	y[0] = z[1] * x[2] - z[2] * x[1];
	y[1] = -z[0] * x[2] + z[2] * x[0];
	y[2] = z[0] * x[1] - z[1] * x[0];
	
	/* mpichler, 19950515 */
	/* cross product gives area of parallelogram, which is < 1.0 for
	 * non-perpendicular unit-length vectors; so normalize x, y here
	 */
	
	mag = sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
	if (mag) {
		x[0] /= mag;
		x[1] /= mag;
		x[2] /= mag;
	}
	
	mag = sqrt(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
	if (mag) {
		y[0] /= mag;
		y[1] /= mag;
		y[2] /= mag;
	}
	
#define M(row,col)  m[col*4+row]
	M(0, 0) = x[0];
	M(0, 1) = x[1];
	M(0, 2) = x[2];
	M(0, 3) = 0.0;
	M(1, 0) = y[0];
	M(1, 1) = y[1];
	M(1, 2) = y[2];
	M(1, 3) = 0.0;
	M(2, 0) = z[0];
	M(2, 1) = z[1];
	M(2, 2) = z[2];
	M(2, 3) = 0.0;
	M(3, 0) = 0.0;
	M(3, 1) = 0.0;
	M(3, 2) = 0.0;
	M(3, 3) = 1.0;
#undef M
	glRotatef(90,0,0,1);
	glMultMatrixf(m);
	/* Translate Eye to Origin */
	glTranslatef(-eyex, -eyey, -eyez);
	
}

/*
 * matrix and math utility routines and macros
 */

void matrixConcatenate (float *result, float *ma, float *mb)
{
    int i;
    GLfloat mb00, mb01, mb02, mb03,
	mb10, mb11, mb12, mb13,
	mb20, mb21, mb22, mb23,
	mb30, mb31, mb32, mb33;
    GLfloat mai0, mai1, mai2, mai3;
	
    mb00 = mb[0];  mb01 = mb[1];
    mb02 = mb[2];  mb03 = mb[3];
    mb10 = mb[4];  mb11 = mb[5];
    mb12 = mb[6];  mb13 = mb[7];
    mb20 = mb[8];  mb21 = mb[9];
    mb22 = mb[10];  mb23 = mb[11];
    mb30 = mb[12];  mb31 = mb[13];
    mb32 = mb[14];  mb33 = mb[15];
	
    for (i = 0; i < 4; i++) {
        mai0 = ma[i*4+0];  mai1 = ma[i*4+1];
	    mai2 = ma[i*4+2];  mai3 = ma[i*4+3];
		
        result[i*4+0] = mai0 * mb00 + mai1 * mb10 + mai2 * mb20 + mai3 * mb30;
        result[i*4+1] = mai0 * mb01 + mai1 * mb11 + mai2 * mb21 + mai3 * mb31;
        result[i*4+2] = mai0 * mb02 + mai1 * mb12 + mai2 * mb22 + mai3 * mb32;
        result[i*4+3] = mai0 * mb03 + mai1 * mb13 + mai2 * mb23 + mai3 * mb33;
    }
}

/*
int gluProject(Vec3 v, MATRIX *modelview, MATRIX *projection, CGRect *viewport, Vec3 *result)
{
}
*/

int gluProject(float objx, float objy, float objz, float *modelview, float *projection, int *viewport, float *windowCoordinate)
{
	//Transformation vectors
	float fTempo[8];
	//Modelview transform
	fTempo[0]=modelview[0]*objx+modelview[4]*objy+modelview[8]*objz+modelview[12];  //w is always 1
	fTempo[1]=modelview[1]*objx+modelview[5]*objy+modelview[9]*objz+modelview[13];
	fTempo[2]=modelview[2]*objx+modelview[6]*objy+modelview[10]*objz+modelview[14];
	fTempo[3]=modelview[3]*objx+modelview[7]*objy+modelview[11]*objz+modelview[15];
	//Projection transform, the final row of projection matrix is always [0 0 -1 0]
	//so we optimize for that.
	fTempo[4]=projection[0]*fTempo[0]+projection[4]*fTempo[1]+projection[8]*fTempo[2]+projection[12]*fTempo[3];
	fTempo[5]=projection[1]*fTempo[0]+projection[5]*fTempo[1]+projection[9]*fTempo[2]+projection[13]*fTempo[3];
	fTempo[6]=projection[2]*fTempo[0]+projection[6]*fTempo[1]+projection[10]*fTempo[2]+projection[14]*fTempo[3];
	fTempo[7]=-fTempo[2];
	//The result normalizes between -1 and 1
	if(fTempo[7]==0.0)	//The w value
		return 0;
	fTempo[7]=1.0/fTempo[7];
	//Perspective division
	fTempo[4]*=fTempo[7];
	fTempo[5]*=fTempo[7];
	fTempo[6]*=fTempo[7];
	//Window coordinates
	//Map x, y to range 0-1
	windowCoordinate[0]=(fTempo[4]*0.5+0.5)*viewport[2]+viewport[0];
	windowCoordinate[1]=(fTempo[5]*0.5+0.5)*viewport[3]+viewport[1];
	//This is only correct when glDepthRange(0.0, 1.0)
	windowCoordinate[2]=(1.0+fTempo[6])*0.5;	//Between 0 and 1
	return 1;
}


bool gluUnProject(Vec3 win,
			 MATRIX *mV, MATRIX *mP,
			 GLint *viewport,
			 Vec3 *obj)
{
	MATRIX m;
	MATRIX A;
	Vec4 pIn, pOut;

	/* transformation coordonnees normalisees entre -1 et 1 */
	pIn.x = (win.x - viewport[0]) * 2 / (float)viewport[2] - 1.0;
	pIn.y = (win.y - viewport[1]) * 2 / (float)viewport[3] - 1.0;
	pIn.z = 2 * win.z - 1.0;
	pIn.w = 1.0;
	
	/* calcul transformation inverse */
	MatrixMultiply(A, *mV, *mP);
	MatrixInverseEx(m, A);
	MatrixVec4Multiply(pOut, pIn, m);
	
	if (pOut.w == 0.0)
		return GL_FALSE;
	pOut.w = 1/pOut.w;
	obj->x = (pOut.x * pOut.w);
	obj->y = (pOut.y * pOut.w);
	obj->z = (pOut.z * pOut.w);
	return GL_TRUE;
}



/**************************************************************************/
/* Checks an array of "count" vertices to see whether they lie in the 
/* bounding volume defined by planeEqs.  Cull the object if the return
/* value is true.
/*
/* Adapted from an example at OpenGL.org
/***************************************************************************/

bool glVertexCulled (Vertex3D *v, int count, float (*planeEqs)[4])
{
    int i, j;
    int culled;
	GLfloat vtx[3];
	
    for (i=0; i<6; i++)
	{
        culled = 0;
        for (j=0; j<count; j++)
		{
			vtx[0] = v[count].x; vtx[1]=v[count].y; vtx[2]=v[count].z;
            if (distanceFromPlane(planeEqs[i], vtx) < -10.f)culled ++;
        }
        if (culled==count)
		/* All eight vertices are trivially culled */
        return true;
    }
    /* Not trivially culled. Probably visible. */
    return false;
}


/**************************************************************************/
/* Calculates an array of functions defining the 6 bounding planes for
/* a given set of MODELVIEW and PROJECTION matrices
/*
/* Lifted from an example at OpenGL.org.. Thanks!
/***************************************************************************/

void glCalcViewVolumePlanes (float (*planeEqs)[4])
{
    GLfloat ocEcMat[16], ecCcMat[16], ocCcMat[16];
	
	
    /* Get the modelview and projection matrices */
    glGetFloatv (GL_MODELVIEW_MATRIX, ocEcMat);
    glGetFloatv (GL_PROJECTION_MATRIX, ecCcMat);
	
    // ocCcMat transforms from OC (object coordinates) to CC (clip coordinates) 
    matrixConcatenate (ocCcMat, ocEcMat, ecCcMat);
	
    // Calculate the six OC plane equations. 
    planeEqs[0][0] = ocCcMat[3] - ocCcMat[0]; 
    planeEqs[0][1] = ocCcMat[7] - ocCcMat[4]; 
    planeEqs[0][2] = ocCcMat[11] - ocCcMat[8]; 
    planeEqs[0][3] = ocCcMat[15] - ocCcMat[12]; 
	
    planeEqs[1][0] = ocCcMat[3] + ocCcMat[0]; 
    planeEqs[1][1] = ocCcMat[7] + ocCcMat[4]; 
    planeEqs[1][2] = ocCcMat[11] + ocCcMat[8]; 
    planeEqs[1][3] = ocCcMat[15] + ocCcMat[12]; 
	
    planeEqs[2][0] = ocCcMat[3] + ocCcMat[1]; 
    planeEqs[2][1] = ocCcMat[7] + ocCcMat[5]; 
    planeEqs[2][2] = ocCcMat[11] + ocCcMat[9]; 
    planeEqs[2][3] = ocCcMat[15] + ocCcMat[13]; 
	
    planeEqs[3][0] = ocCcMat[3] - ocCcMat[1]; 
    planeEqs[3][1] = ocCcMat[7] - ocCcMat[5]; 
    planeEqs[3][2] = ocCcMat[11] - ocCcMat[9]; 
    planeEqs[3][3] = ocCcMat[15] - ocCcMat[13]; 
	
    planeEqs[4][0] = ocCcMat[3] + ocCcMat[2]; 
    planeEqs[4][1] = ocCcMat[7] + ocCcMat[6]; 
    planeEqs[4][2] = ocCcMat[11] + ocCcMat[10]; 
    planeEqs[4][3] = ocCcMat[15] + ocCcMat[14]; 
	
    planeEqs[5][0] = ocCcMat[3] - ocCcMat[2]; 
    planeEqs[5][1] = ocCcMat[7] - ocCcMat[6]; 
    planeEqs[5][2] = ocCcMat[11] - ocCcMat[10]; 
    planeEqs[5][3] = ocCcMat[15] - ocCcMat[14]; 
	
}



void gluSetDefault3DStates()
{
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	//Point Sprite Parameters
	
	CGRect b = ScaledBounds();
	float sf = 1 * b.size.width/320;
	
	glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	glPointParameterf( GL_POINT_FADE_THRESHOLD_SIZE, 1.0f );
	glPointParameterf(GL_POINT_SIZE_MIN, 1*sf);
	glPointParameterf(GL_POINT_SIZE_MAX, 64*sf);
	const float quadratic[] =  { 1.0f, .025f, 0.000000f };
	glPointParameterfv( GL_POINT_DISTANCE_ATTENUATION, quadratic );
	glPointSize(64);
	
	glEnable(GL_LIGHTING);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glEnable(GL_POINT_SPRITE_OES);
	glDisable(GL_COLOR_MATERIAL);
	glShadeModel(GL_SMOOTH);
	glDepthFunc(GL_LEQUAL);
	glDisable(GL_RESCALE_NORMAL);
	glDisable(GL_NORMALIZE);
	
	glDefaultMaterial();
	//Color3D c = Color3DMake(.2, .2, .2, 1);
	//gluAmbientLightWithColor(c);

	
}

void gluAmbientLightWithColor(Color3D c)
{
	const GLfloat lightAmbient[] = {c.red, c.green, c.blue, c.alpha};

	glEnable(GL_LIGHT0);
	const GLfloat	lightZero[] = {0,0,0,0};
	
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightZero);
	glLightfv(GL_LIGHT0, GL_SPECULAR, lightZero);;
	
}


void gluAmbientLight(Color3D *col)
{
	const GLfloat	lightAmbient[] = {col->red, col->green, col->blue, col->alpha};
	const GLfloat	lightZero[] = {0,0,0,0};
	
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightZero);
	glLightfv(GL_LIGHT0, GL_SPECULAR, lightZero);
	//glDisable(GL_LIGHT1);
}


void gluDefault3DLights()
{
	//const GLfloat global_ambient[] = { 0.6f, 0.6f, 0.6f, 1.0f };
	//glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);
	
	const GLfloat	lightAmbient[] = {0.6, .6, 0.6, 1.0};
	//glDisable(GL_LIGHT0);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glDisable(GL_LIGHT1);
	
}

void gluLightFromPoint(Vector3D *p, GLenum lightNumber)
{
	Color3D c = Color3DMake(.6,.6,.6,1);
	gluLightFromPoint(p, lightNumber, &c);
}


void gluLightFromPoint(Vector3D *p, GLenum lightNumber, Color3D *c)
{
	const GLfloat			lightDiffuse[] = {c->red,c->green, c->blue, c->alpha};
	const GLfloat			lightPosition[] = {p->x, p->y, p->z,1.0}; 
	//glLightf(lightNumber,  GL_LINEAR_ATTENUATION, .05);
		glLightfv(lightNumber, GL_DIFFUSE, lightDiffuse);
		glLightfv(lightNumber, GL_POSITION, lightPosition); 
		glLightfv(lightNumber, GL_SPECULAR, lightDiffuse);	

}

void gluLightFromPoint2(Vector3D *p, GLenum lightNumber, Color3D *c)
{
	const GLfloat			lightDiffuse[] = {c->red,c->green, c->blue, c->alpha};
	const GLfloat			lightPosition[] = {p->x, p->y, p->z,0.0}; 
	//glLightf(lightNumber,  GL_LINEAR_ATTENUATION, .05);
	glLightfv(lightNumber, GL_DIFFUSE, lightDiffuse);
	glLightfv(lightNumber, GL_POSITION, lightPosition); 
	glLightfv(lightNumber, GL_SPECULAR, lightDiffuse);	
	
}

void gluLightFromPointWithColors(Vector3D *p, GLenum lightNumber, Color3D diffuse, Color3D specular)
{
	const GLfloat			lightDiffuse[] = {0.8, 0.8, .8, 1.0};
	const GLfloat			lightSpecular[] = {.8,.8,.8,1.0};
	const GLfloat			lightPosition[] = {p->x, p->y, p->z, 0.0}; 
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glLightfv(lightNumber, GL_DIFFUSE, lightDiffuse);
	glLightfv(lightNumber, GL_POSITION, lightPosition); 
	glLightfv(lightNumber, GL_SPECULAR, lightSpecular);	
	
	glPopMatrix();
}



void gluDefault2DLights()
{
	const GLfloat			lightAmbient[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	
	const GLfloat			lightPosition[] = {0, -5, 20, 0.0}; 
	//const GLfloat			lightShininess = 2.0;
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 

	glPopMatrix();
}

void gluSetDefault2DStates()
{
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glDisable(GL_LIGHTING);
	glDisable(GL_CULL_FACE);
	glDisable(GL_FOG);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(1,1,1,1);
}


void glDefaultMaterial()
{
	const Color3D ambient = Color3DMake(1,1,1,1);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&ambient);
	
	const Color3D diffuse = Color3DMake(1,1,1,1);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,  (const GLfloat *)&diffuse);
	
	//const Color3D specular = Color3DMake(.7,.7,.7,1);
	//glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&specular);
	//glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 25);
}	


void gluSetDefault2DProjection()
{
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity();
	
	CGRect bounds = ScaledBounds();
	
	glOrthof(0, bounds.size.width, 0, bounds.size.height, .1, 2000);
	glViewport(0, 0, bounds.size.width, bounds.size.height);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	if([[qrGameState sharedqrGameState] screenFlipped]){
		glTranslatef(bounds.size.width,bounds.size.height,0);
		glRotatef(180, 0, 0,1);
	}
}

void gluClearErrors()
{
	GLenum err = glGetError();
	while(err){
		printf("Clearing openGL Errors-> Error Detect: %d",err);
		err=glGetError(); // Clear an errors...
	}
}

CGRect scaleRect(const CGRect &rect, float scale)
{
	float s_width = rect.size.width * scale;
	float s_height = rect.size.height * scale;
	
	float w_offset = (s_width - rect.size.width)/2;
	float h_offset = (s_height - rect.size.height)/2;
	
	return CGRectMake(rect.origin.x - w_offset, rect.origin.y - h_offset, s_width, s_height);
}

CGRect ScaledBounds()
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	float scale = ScreenScale();
	return CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width*scale,bounds.size.height*scale);
}

float ScreenScale()
{
	float scale = 1;
	if([[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")]){
		UIScreen *screen = [UIScreen mainScreen];
		scale = screen.scale;
	}
	return scale;
}

void ScaleTouch(CGPoint *t)
{
	float scale = ScreenScale();
	t->x = t->x * scale;
	t->y = t->y * scale;
}

void shuffleArray(NSMutableArray* a)
{
	for (int r=0; r<5; r++){
		for (int i=0; i<[a count]; i++) {
			int d= (random() % ([a count] -i));
			id temp=[a objectAtIndex:d];
			
			[a removeObjectAtIndex:d];
			[a addObject:temp];
		}
	}
}

void PostNotification(NSString *name, id object)
{
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	NSNotification *n = [NSNotification notificationWithName:name object:object];
	[ns postNotification:n];
}

void PostNotification(NSString *name)
{
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	NSNotification *n = [NSNotification notificationWithName:name object:nil];
	[ns postNotification:n];
}


void ObserveNotification(id target, SEL selector, NSString *name)
{
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	[ns addObserver:target selector:selector name:name object:nil];
}

void ObserveNotification(id target, SEL selector, NSString *name, id object)
{
	NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
	[ns addObserver:target selector:selector name:name object:object];
}

/*
inline void iPadScaleRect(CGRect *r)
{
	CGRect bounds = [[UIScreen mainScreen] bounds];
	r->origin.x *= bounds.size.width/320.0f;
	r->origin.y *= bounds.size.height/480.0f;
	r->size.width *= bounds.size.width/320.0f;
	r->size.height *= bounds.size.height/480.0f;
}*/



