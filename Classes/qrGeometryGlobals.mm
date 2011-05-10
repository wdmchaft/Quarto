//
//  qrGeometryGlobals.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-24.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrGeometryGlobals.h"


@implementation qrGeometryGlobals

SYNTHESIZE_SINGLETON_FOR_CLASS(qrGeometryGlobals)

-(void)saveMVPMatrices
{
	GLfloat modelview[16];
	GLfloat projection[16];
	
	glGetFloatv( GL_MODELVIEW_MATRIX, modelview );
	glGetFloatv( GL_PROJECTION_MATRIX, projection );
	glGetIntegerv( GL_VIEWPORT, _viewPort );
	
	MatrixCopy(modelview, _modelViewMatrix);
	MatrixCopy(projection, _projectionMatrix);
}



-(MATRIX)modelViewMatrix
{
	return _modelViewMatrix;
}

-(MATRIX)projectionMatrix
{
	return _projectionMatrix;
}

-(GLint*)viewPort
{
	return _viewPort;
}

@end
