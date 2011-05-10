/*
 *  glUtility.h
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 07/03/09.
 *  Copyright 2009 Barn*Star Studios. All rights reserved.
 *
 */

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

#define vectorLength(nin) \
sqrt((nin)[0]*(nin)[0] + (nin)[1]*(nin)[1] + (nin)[2]*(nin)[2])

#define distanceFromPlane(peq,p) \
((peq)[0]*(p)[0] + (peq)[1]*(p)[1] + (peq)[2]*(p)[2] + (peq)[3])

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OpenGLCommon.h"
#import "vrConstants.h"
#import "qrGameState.h"
#import "vrMath.h"

void shuffleArray(NSMutableArray* a);

void PostNotification(NSString *name);
void PostNotification(NSString *name, id object);
void ObserveNotification(id target, SEL selector, NSString *name);
void ObserveNotification(id target, SEL selector, NSString *name, id object);

//iPhone 4 Screen Scaling Support
float ScreenScale();
CGRect ScaledBounds();
void ScaleTouch(CGPoint *t);

CGRect scaleRect(const CGRect &rect, float scale);

bool gluLoadTexture(NSString *filename, GLuint texture, GLenum min_filter);

void gluDrawSegment(Vec3 *v1, Vec3 *v2, Color3D *color, GLfloat width);
void gluDrawRect(CGRect r, GLfloat depth, Color3D *color, GLfloat width);

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx, GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy, GLfloat upz);

int gluProject(float objx, float objy, float objz, float *modelview, float *projection, int *viewport, float *windowCoordinate);
bool gluUnProject(Vec3 win, MATRIX *mV, MATRIX *mP, GLint *viewport, Vec3 *obj);
void matrixConcatenate (float *result, float *ma, float *mb);

bool glVertexCulled (Vertex3D *v, int count, float (*planeEqs)[4]);

void glCalcViewVolumePlanes (float (*planeEqs)[4]);

void glDefaultMaterial();

void gluSetDefault3DStates();
void gluSetDefault2DStates();
void gluSetDefault2DProjection();

void gluDefault3DLights();
void gluAmbientLight(Color3D *col);
void gluDefault2DLights();

void gluLightFromPoint(Vector3D *p, GLenum lightNumber);
void gluLightFromPoint(Vector3D *p, GLenum lightNumber, Color3D *c);
void gluLightFromPoint2(Vector3D *p, GLenum lightNumber, Color3D *c);

void gluAmbientLightWithColor(Color3D c);
void gluLightFromPointWithColors(Vector3D *p, GLenum lightNumber, Color3D diffuse, Color3D specular);

void gluClearErrors();
//inline void iPadScaleRect(CGRect *r);
