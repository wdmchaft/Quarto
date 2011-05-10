//
//  qrGeometryGlobals.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-24.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrMath.h"
#import "OpenGLCommon.h"
#import "SynthesizeSingleton.h"

@interface qrGeometryGlobals : NSObject {
	GLint		_viewPort[4];
	MATRIX		_modelViewMatrix;
	MATRIX		_projectionMatrix;
}

+(qrGeometryGlobals *)sharedqrGeometryGlobals;

-(void)saveMVPMatrices;
-(MATRIX)modelViewMatrix;
-(MATRIX)projectionMatrix;
-(GLint*)viewPort;


@end
