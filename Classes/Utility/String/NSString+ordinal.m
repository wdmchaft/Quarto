//
//  NSString+ordinal.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 06/11/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "NSString+ordinal.h"


@implementation NSString(ordinal)

+(NSString *)ordinalFromInt:(int)val
{
	switch(val){
		case 1:
			return @"1st";
		case 2:
			return @"2nd";
		case 3:
			return @"3rd";
		default:
			return [NSString stringWithFormat:@"%dth",val];
	}
}

@end
