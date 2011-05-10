//
//  qrNetworkMove.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrNetworkMove.h"


@implementation qrNetworkMove

@synthesize isControlPacket = _isControlPacket;
@synthesize netControlData = _netControlData;

@synthesize nextPieceBitmask = _nextPieceBitmask;
@synthesize lastPiecePlacement = _lastPiecePlacement;
@synthesize lastPieceBitmask = _lastPieceBitmask;
@synthesize resetBoard = _resetBoard;

-(id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	if(self){
		_resetBoard = NO;
		
		_isControlPacket = [decoder decodeBoolForKey:@"controlPacket"];
		if(_isControlPacket){
			NSData *ncd = [decoder decodeObjectForKey:@"netControlData"];
			[ncd getBytes:(void*)(&_netControlData) length:sizeof(qrNetControlData)];
		}
		else{
			_nextPieceBitmask = [decoder decodeIntForKey:@"npb"];
			_lastPieceBitmask = [decoder decodeIntForKey:@"lpb"];
			_lastPiecePlacement = [decoder decodeIntForKey:@"lpp"];
			_resetBoard = [decoder decodeBoolForKey:@"reset"];
		}		
	}
	return self;
}


-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBool:_isControlPacket forKey:@"controlPacket"];
	if(_isControlPacket){
		NSData *d = [NSData dataWithBytes:&_netControlData length:sizeof(qrNetControlData)];
		[coder encodeObject:d forKey:@"netControlData"];
	}
	else{
		[coder encodeInt:_nextPieceBitmask forKey:@"npb"];
		[coder encodeInt:_lastPieceBitmask forKey:@"bpb"];
		[coder encodeInt:_lastPiecePlacement forKey:@"lpp"];
		[coder encodeBool:_resetBoard forKey:@"reset"];
	}
}

@end
