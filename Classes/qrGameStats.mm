//
//  qrGameStats.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-06.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrGameStats.h"


@implementation qrGameStats

@synthesize   spwins	= _spwins;
@synthesize   splosses	= _splosses;
@synthesize   spdraws	= _spdraws;

@synthesize   tpwins	= _tpwins;
@synthesize   tplosses	= _tplosses;
@synthesize   tpdraws	= _tpdraws;

-(id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if(self)
	{
		self.spwins		= [coder decodeIntForKey:@"spwins"];
		self.splosses	= [coder decodeIntForKey:@"splosses"];
		self.spdraws	= [coder decodeIntForKey:@"spdraws"];
		
		self.tpwins		= [coder decodeIntForKey:@"tpwins"];
		self.tplosses	= [coder decodeIntForKey:@"tplosses"];
		self.tpdraws	= [coder decodeIntForKey:@"tpdraws"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:self.spwins forKey:@"spwins"];
	[coder encodeInt:self.splosses forKey:@"splosses"];
	[coder encodeInt:self.spdraws forKey:@"spdraws"];
	
	[coder encodeInt:self.tpwins forKey:@"tpwins"];
	[coder encodeInt:self.tplosses forKey:@"tplosses"];
	[coder encodeInt:self.tpdraws forKey:@"tpdraws"];
}

-(void)saveToUserDefaults:(NSString *)name
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSData *stats = [NSKeyedArchiver archivedDataWithRootObject:self];
	[ud setObject:stats forKey:name];
}
					 
+(qrGameStats *)loadFromUserDefaults:(NSString *)name
{
	qrGameStats *ret = nil;
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSData *stats = [ud objectForKey:name];
	
	if(stats){
		ret = [NSKeyedUnarchiver unarchiveObjectWithData:stats];
	}
	return ret;	
}


-(void)clearStats
{
	self.spwins = 0;
	self.splosses = 0;
	self.spdraws = 0;
	self.tpwins = 0;
	self.tplosses = 0;
	self.tpdraws = 0;
}

@end
