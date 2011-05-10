//
//  qrPiece.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrPiece.h"
#import "vrModelPool.h"

/***************************************************
/* BITMASK DEFINITION
/*
/*		0          0           0           0
/*     Tip		 Shape		 Size		 Color
/*   0-None    0-Square     0-Short     0-Light
/*   1-Indent  1-Round      1-Tall      1-Dark
/*
/*
/* BITMASK			TIP			SHAPE		SIZE		COLOR
/* 
/* 0000 (0)		-	Flat		Square		Short		Light
/* 0001 (1)		-	Flat		Square		Short		Dark
/* 0010 (2)		-	Flat		Square		Tall		Light
/* 0011 (3)		-	Flat		Square		Tall		Dark
/* 0100	(4)		-	Flat		Round		Short		Light
/* 0101	(5)		-	Flat		Round		Short		Dark
/* 0110	(6)		-	Flat		Round		Tall		Light
/* 0111	(7)		-	Flat		Round		Tall		Dark
/* 1000 (8)		-	Indent		Square		Short		Light
/* 1001 (9)		-	Indent		Square		Short		Dark
/* 1010 (10)	-	Indent		Square		Tall		Light
/* 1011 (11)	-	Indent		Square		Tall		Dark
/* 1100	(12)	-	Indent		Round		Short		Light
/* 1101	(13)	-	Indent		Round		Short		Dark
/* 1110	(14)	-	Indent		Round		Tall		Light
/* 1111	(15)	-	Indent		Round		Tall		Dark
/*********************************************************************/

@implementation qrPiece

@synthesize tip = _tip;
@synthesize shape = _shape;
@synthesize color = _color;
@synthesize size = _size;
@synthesize isNull = _isNull;
@synthesize model = _model;
@synthesize placeAnimation = _placeAnimation;

-(id)initNullPiece
{
	self = [super init];
	if(self){
		_isNull = YES;
	}
	return self;
}
	
	
-(id)initFromBitMask:(unsigned char)bitMask
{
	self = [super init];
	if(self){
		_bitMask = bitMask;
		[self setPropertiesFromBitmask:_bitMask];
		[self loadModelWithMask:_bitMask];
		_isNull = NO;
	}
	return self;
}


+(qrPiece *)nullPiece
{
	qrPiece *p = [[[qrPiece alloc] initNullPiece] autorelease];
	return p;
}

-(void)loadModelWithMask:(int)bitMask
{
	NSString *fName = [[self fileNameFromProperties] retain];
	vrModelPool *modelPool = [vrModelPool sharedvrModelPool];
	_model = [modelPool objectForKey:fName];
	if(!_model)NSLog(@"Error Loading Model For Piece with Key: %@",fName);
	else LOG(NSLog(@"Loaded Piece Model: %@",fName));

	[fName release];
}

-(NSString*)fileNameFromProperties
{
	NSMutableString *fName = [[NSMutableString alloc] init];
	
	NSString *zero = [[NSString alloc] initWithString:@"0"];
	NSString *one  = [[NSString alloc] initWithString:@"1"];
	
	[fName appendFormat:@"p"];
	
	(_tip)		? [fName appendString:one] : [fName appendString:zero];
	(_shape)	? [fName appendString:one] : [fName appendString:zero];
	(_size)		? [fName appendString:one] : [fName appendString:zero];
	(_color)	? [fName appendString:one] : [fName appendString:zero];
	
	[zero release];
	[one release];
	
	NSString *ret = [[[NSString alloc] initWithString:fName] autorelease];
	[fName release];
	
	return ret;
}

-(void)setPropertiesFromBitmask:(unsigned char)bitMask
{
	_color	= (_bitMask & 1) ? YES : NO;
	_size	= (_bitMask & 2) ? YES : NO;
	_shape	= (_bitMask & 4) ? YES : NO;
	_tip	= (_bitMask & 8) ? YES : NO;
}

-(unsigned char)bitMask
{
	_bitMask = 0;
	if(_color)_bitMask	+= 1;
	if(_size) _bitMask	+= 2;
	if(_shape)_bitMask	+= 4;
	if(_tip)  _bitMask	+= 8;
	return _bitMask;
}

-(void)printBitMask
{
	static char b[9];
    b[0] = '\0';
	
    int z;
    for (z = 128; z > 0; z >>= 1)
    {
        strcat(b, ((_bitMask & z) == z) ? "1" : "0");
    }
	printf("BitMask: %s\n", b);
}

-(void)dealloc
{
	[_placeAnimation release];
	[super dealloc];
}

@end
