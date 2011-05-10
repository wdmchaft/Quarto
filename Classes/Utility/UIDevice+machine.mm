//
//  UIDevice+machine.m
//  VectorRacer
//
//  Created by Jonathan Nobels on 06/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//


#import "UIDevice+machine.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice(machine)

- (NSString *)machine
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = (char*)malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
	
	// Done with this
	free(name);
	
	return machine;
}

- (NSString *) platformString{
	NSString *platform = [self machine];
	if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
	if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
	if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
	if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
	if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
	if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
	if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
	return platform;
}


- (DeviceGen) deviceGeneration{
	NSString *platform = [self machine];
	//NSLog(@"Platform String: %@",platform);
	if ([platform isEqualToString:@"iPhone1,1"]) return kFirstGen;
	if ([platform isEqualToString:@"iPhone1,2"]) return kSecondGen;
	if ([platform isEqualToString:@"iPhone2,1"]) return kThirdGen;
	if ([platform isEqualToString:@"iPod1,1"])   return kFirstGen;
	if ([platform isEqualToString:@"iPod2,1"])   return kSecondGen;
	if ([platform isEqualToString:@"iPad1,1"])   return kThirdGen;
	if ([platform hasPrefix:@"iPad"])			 return kThirdGen;
	if ([platform isEqualToString:@"i386"])		 return kSimulator;
	return kThirdGen;
}

- (DeviceType) deviceType{
	NSString *platform = [self machine];
	//NSLog(@"Platform String: %@",platform);
	if([platform hasPrefix:@"iPhone"])return kiPhoneDevice;
	if([platform hasPrefix:@"iPad"])return kiPadDevice;
	if([platform hasPrefix:@"iPod"])return kiPodDevice;
	return kUnknownDevice;
}

-(NSString *)devicePrefix
{
	NSString *platform = [self machine];
	if([platform hasPrefix:@"iPhone"])return @"iPhone";
	if([platform hasPrefix:@"iPad"])return @"iPad";
	if([platform hasPrefix:@"iPod"])return @"iPod";
	return @"Computer";
}

@end