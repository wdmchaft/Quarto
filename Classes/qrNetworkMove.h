//
//  qrNetworkMove.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-04.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct{
	int		pingCount;
	BOOL	reply;
}qrNetControlData;

@interface qrNetworkMove : NSObject <NSCoding> {
	BOOL	_isControlPacket;
	qrNetControlData _netControlData;
	
	int		_nextPieceBitask;
	int		_lastPiecePlacement;
	int		_lastPieceBitask;
	BOOL	_resetBoard;
}

@property (nonatomic) BOOL isControlPacket;
@property (nonatomic) qrNetControlData netControlData;

@property (nonatomic) int nextPieceBitmask;
@property (nonatomic) int lastPiecePlacement;
@property (nonatomic) int lastPieceBitmask;
@property (nonatomic) BOOL resetBoard;

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)coder;


@end
