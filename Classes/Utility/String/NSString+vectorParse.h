//
//  NSString+vectorParse.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 16/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLCommon.h"
#import "vrTypeDefs.h"

@interface NSString(vectorParse)

//Methods return a complete structure from a comma delimited string
// IN:  @"6,7,8" 
// OUT: Vector3DMake(6,7,8)

+(Vector3D)vector3DFromCDS:(NSString *)string;
+(Color3D)colorFromCDS:(NSString *)string; 
+(ControlRect)controlRectFromCDS:(NSString *)string; 

-(Vector3D)vector3DFromCDS;
-(Color3D)colorFromCDS;
-(ControlRect)controlRectFromCDS; 

-(NSString *)fileNameFromPath;


@end
