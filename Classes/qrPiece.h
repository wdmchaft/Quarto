//
//  qrPiece.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vr3DModel.h"
#import "qrAnimation.h"

@interface qrPiece : NSObject {
	BOOL _color;
	BOOL _size;
	BOOL _shape;
	BOOL _tip;
	unsigned char _bitMask;
	
	vr3DModel	*_model;
	
	//BOOL		_inPlay;
	//int		_column;
	//int		_row;
	
	BOOL		_isNull;
	
	qrAnimation *_placeAnimation;
}

@property (nonatomic, readonly) BOOL color;
@property (nonatomic, readonly) BOOL size;
@property (nonatomic, readonly) BOOL shape;
@property (nonatomic, readonly) BOOL tip;
@property (nonatomic, readonly) BOOL isNull;
@property (nonatomic, readonly) vr3DModel *model;
@property (nonatomic, retain) qrAnimation *placeAnimation;

-(id)initFromBitMask:(unsigned char)bitMask;
-(id)initNullPiece;

+(qrPiece *)nullPiece;

-(void)setPropertiesFromBitmask:(unsigned char)bitMask;
-(void)loadModelWithMask:(int)bitMask;
-(NSString*)fileNameFromProperties;

-(unsigned char)bitMask;
-(void)printBitMask;


@end
