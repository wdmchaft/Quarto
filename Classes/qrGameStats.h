//
//  qrGameStats.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-06.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface qrGameStats : NSObject <NSCoding> {
	int		_spwins;
	int		_splosses;
	int		_spdraws;
	
	int		_tpwins;
	int		_tplosses;
	int		_tpdraws;
}

@property (nonatomic) int spwins;
@property (nonatomic) int splosses;
@property (nonatomic) int spdraws;

@property (nonatomic) int tpwins;
@property (nonatomic) int tplosses;
@property (nonatomic) int tpdraws;

-(id)initWithCoder:(NSCoder *)coder;
-(void)encodeWithCoder:(NSCoder *)coder;

-(void)saveToUserDefaults:(NSString *)name;
+(qrGameStats *)loadFromUserDefaults:(NSString *)name;

-(void)clearStats;

@end
