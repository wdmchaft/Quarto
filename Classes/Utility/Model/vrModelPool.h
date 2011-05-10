//
//  vrModelPool.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "vr3DModel.h"

@interface vrModelPool : NSObject {
	NSMutableDictionary		*_modelPool;
}

+(vrModelPool*)sharedvrModelPool;
-(NSMutableDictionary *)getPool;

-(void)addModelsFromFile:(NSString *)plist;
-(void)addModel:(vr3DModel *)model withKey:(NSString *)key;

-(void)removeModelsFromFile:(NSString *)plist;
-(void)removeModelForKey:(NSString *)key;

-(void)addModelsFromFile:(NSString *)plist inSet:(NSSet *)keys;
-(void)removeModelsInSet:(NSSet *)keys;


-(vr3DModel *)objectForKey:(NSString *)key;

@end
