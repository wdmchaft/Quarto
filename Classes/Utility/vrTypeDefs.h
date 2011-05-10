/*
 *  vrTypeDefs.h
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 07/03/09.
 *  Copyright 2009 Barn*Star Studios. All rights reserved.
 *
 */
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>


#define randomf()	(float)(rand()/((double)RAND_MAX + 1))
#define numof(x)	(sizeof (x) / sizeof *(x))



typedef struct {
	GLfloat x;
	GLfloat y;
}vrVector2D;


static inline vrVector2D vrVector2DMake(float x, float y)
{
	vrVector2D ret;
	ret.x = x; ret.y = y;
	return ret;
}


typedef struct {
	
	GLfloat left;
	GLfloat right;
	GLfloat top;
	GLfloat bottom;

}ControlRect;


static inline ControlRect ControlRectMake(GLfloat left, GLfloat right, GLfloat top, GLfloat bottom)
{
	ControlRect ret;
	ret.left = left;
	ret.right = right;
	ret.top = top;
	ret.bottom = bottom;
	return ret;
}


static inline CGRect CGRectFromControlRect(ControlRect _cR)
{
	float scale = 1;
	if([[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")]){
		UIScreen *screen = [UIScreen mainScreen];
		scale = screen.scale;
	}
	float height = [[UIScreen mainScreen] bounds].size.height * scale;
	return CGRectMake(_cR.left, height-_cR.bottom,_cR.right-_cR.left, (_cR.bottom-_cR.top));
}


typedef enum {
	kTouchSingle = 1,
	kTouchSwipeLeft,
	kTouchSwipeRight,
	kTouchSwipeUp,
	kTouchSwipeDown,
}vrTouchType;


typedef enum {
	kHorizontal=1,
	kVertical,
} vrOrientation;

typedef enum {
	kSlide=1,
	kFade,
	kDisolve,
	kSpin,
} vrUITransition;
