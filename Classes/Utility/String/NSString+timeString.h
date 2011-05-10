//
//  NSString+timeString.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 03/11/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(timeString)

+(NSString*)timeStringFromSeconds:(double)time;
+(NSString*)timeStringFromSecondsWithTenths:(double)time;

@end
