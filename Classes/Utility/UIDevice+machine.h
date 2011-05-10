//
//  UIDevice+machine.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 06/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum {
	kFirstGen = 1,
	kSecondGen,
	kThirdGen,
	kSimulator,
	kUnknownGen,
	kiPad,
}DeviceGen;

typedef enum {
	kiPhoneDevice =1,
	kiPadDevice,
	kiPodDevice,
	kUnknownDevice,
}DeviceType;
	

@interface UIDevice(machine)

- (NSString *)machine;
- (NSString *)platformString;
- (DeviceGen) deviceGeneration;
- (DeviceType) deviceType;
-(NSString *)devicePrefix;

@end
