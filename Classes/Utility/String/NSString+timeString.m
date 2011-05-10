//
//  NSString+timeString.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 03/11/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "NSString+timeString.h"


@implementation NSString(timeString)

+(NSString*)timeStringFromSeconds:(double)time{
	int seconds = (int)time % 60;
	int minutes	= (int)time/60;
	
	return [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
}

+(NSString*)timeStringFromSecondsWithTenths:(double)time{
	int seconds = (int)time % 60;
	int minutes	= (int)time/60;
	int tenths	= 10*(double)(time - (int)time);
	
	return [NSString stringWithFormat:@"%d:%02d.%d",minutes,seconds,tenths];
}
@end
