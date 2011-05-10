//
//  NSString+vectorParse.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 16/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "NSString+vectorParse.h"


@implementation NSString(vectorParse)

+(Vector3D)vector3DFromCDS:(NSString *)string
{
	Vector3D ret = Vector3DMake(0,0,0);
	if(!string)return ret;
	NSArray *parts = [string componentsSeparatedByString:@","];
	if(3 == [parts count]){
		ret.x = [[parts objectAtIndex:0] floatValue];
		ret.y = [[parts objectAtIndex:1] floatValue];
		ret.z = [[parts objectAtIndex:2] floatValue];
	}
	return ret;	
}


+(Color3D)colorFromCDS:(NSString *)string
{
	Color3D ret = Color3DMake(0,0,0,0);
	if(!string)return ret;
	NSArray *parts = [string componentsSeparatedByString:@","];
	if(4 == [parts count]){
		ret.red		= [[parts objectAtIndex:0] floatValue];
		ret.green	= [[parts objectAtIndex:1] floatValue];
		ret.blue	= [[parts objectAtIndex:2] floatValue];
		ret.alpha	= [[parts objectAtIndex:3] floatValue];
	}	
	return ret;	
}

+(ControlRect)controlRectFromCDS:(NSString *)string
{
	ControlRect ret = ControlRectMake(0,0,0,0);
	if(!string)return ret;
	NSArray *parts = [string componentsSeparatedByString:@","];
	if(4 == [parts count]){
		ret.left		= [[parts objectAtIndex:0] floatValue];
		ret.right		= [[parts objectAtIndex:1] floatValue];
		ret.top			= [[parts objectAtIndex:2] floatValue];
		ret.bottom		= [[parts objectAtIndex:3] floatValue];
	}	
	return ret;	
}

+(CGRect)CGRectFromCDS:(NSString *)string
{
	CGRect ret = CGRectMake(0,0,0,0);
	if(!string)return ret;
	NSArray *parts = [string componentsSeparatedByString:@","];
	if(4 == [parts count]){
		ret.origin.x	= [[parts objectAtIndex:0] floatValue];
		ret.origin.y	= [[parts objectAtIndex:1] floatValue];
		ret.size.width	= [[parts objectAtIndex:2] floatValue];
		ret.size.height	= [[parts objectAtIndex:3] floatValue];
	}	
	return ret;	
}

-(Vector3D)vector3DFromCDS
{
	return [NSString vector3DFromCDS:self];
}

-(Color3D)colorFromCDS
{
	return [NSString colorFromCDS:self];
}

-(ControlRect)controlRectFromCDS
{
	return [NSString controlRectFromCDS:self];
}

-(NSString *)fileNameFromPath
{
	NSArray *parts = [self componentsSeparatedByString:@"/"];
	return [parts lastObject];
}



@end
