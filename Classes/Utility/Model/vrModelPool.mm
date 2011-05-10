//
//  vrModelPool.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 10/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrModelPool.h"
#import "vrConstants.h"


@implementation vrModelPool

SYNTHESIZE_SINGLETON_FOR_CLASS(vrModelPool)

-(NSMutableDictionary *)getPool
{
	if(!_modelPool)_modelPool = [[NSMutableDictionary alloc] init];
	return _modelPool;
}
/*
-(int)addModels:(NSDictionary *)models 
{
	NSUInteger count = 0;
	
	if(!_modelPool)_modelPool = [[NSMutableDictionary alloc] init];
	
	vr3DModel *model = nil;
	
	for(NSString *key in models){
		
		NSString *fname = [NSString stringWithString:[models objectForKey:key]];
		model = [[vr3DModel alloc] initWithPath:[[NSBundle mainBundle] pathForResource:fname ofType:@"obj"]];
			
		if(model){
			[self addModel:model withKey:key];
			[model release];
			model = nil;
			count++;
		}else{
			NSLog(@"Error Loading Model: %@.obj",fname);
		}
	}
	//[keys release];
	return count;
}


-(BOOL)addModel:(NSString *)fname withType:(NSString *)type withKey:(NSString *)key
{
	if(!_modelPool)_modelPool = [[NSMutableDictionary alloc] init];
	
	vr3DModel *model = [[vr3DModel alloc] 
								initWithPath:[[NSBundle mainBundle]
								pathForResource:fname ofType:type]];
	if(model){
		[_modelPool setObject:model forKey:key];
		[model release];
		return YES;
	}
	return NO;
}

*/

-(void)addModel:(vr3DModel *)model withKey:(NSString *)key
{
	if(!_modelPool)_modelPool = [[NSMutableDictionary alloc] init];
	if(![_modelPool objectForKey:key]){
		[_modelPool setObject:model forKey:key];
		LOG(NSLog(@"Added Model With Key %@ To Model Pool", key));
	}
	return;
}

-(void)addModelsFromFile:(NSString *)plist
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
	NSDictionary *modelList = [NSDictionary dictionaryWithContentsOfFile:path];
	
	LOG(NSLog(@"LOADING DATA: Adding Models From %@.plist",plist));
	
	for(NSString *key in modelList)
	{
		if([_modelPool objectForKey:key]){
			LOG(NSLog(@"LOADING DATA: Retained Model With Key",key));
			[[_modelPool objectForKey:key] retain];
		}
		else{
			LOG(NSLog(@"LOADING DATA: Adding Model With Key: %@",key));
			NSString *path =[[NSBundle mainBundle] pathForResource:[modelList objectForKey:key] ofType:@"obj"];
			//if(path){
			vr3DModel *bg = [[vr3DModel alloc] initWithPath:path modelKey:key];
			
			if(bg){
				[self addModel:bg withKey:key];
				[bg release];
			}
			else{
				NSLog(@"ERROR: Model Data %@ not found for key %@",[modelList objectForKey:key],key);
			}
		}
	}	
	
	[pool release];
}

-(void)addModelsFromFile:(NSString *)plist inSet:(NSSet *)keys
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
	NSDictionary *modelList = [NSDictionary dictionaryWithContentsOfFile:path];
	
	LOG(NSLog(@"LOADING DATA: Adding Models From %@.plist",plist));
	
	for(NSString *key in keys)
	{
		if([_modelPool objectForKey:key]){
			LOG(NSLog(@"LOADING DATA: Retained Model With Key",key));
			[[_modelPool objectForKey:key] retain];
		}
		else{
			LOG(NSLog(@"LOADING DATA: Adding Model With Key: %@",key));
			NSString *path =[[NSBundle mainBundle] pathForResource:[modelList objectForKey:key] ofType:@"obj"];
			vr3DModel *bg = [[vr3DModel alloc] initWithPath:path modelKey:key];
			[self addModel:bg withKey:key];
			[bg release];
		}
	}	
	
	[pool release];
}


-(void)removeModelsInSet:(NSSet *)keys
{
	for(NSString *key in keys)[self removeModelForKey:key];
}	


-(void)removeModelsFromFile:(NSString *)plist
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
	NSDictionary *modelList = [NSDictionary dictionaryWithContentsOfFile:path];
	
	LOG(NSLog(@"Removing Models From %@.plist",plist));
	
	for(NSString *key in modelList)	[self removeModelForKey:key];
		
	[pool release];
}	


-(void)removeModels:(NSArray *)modelKeys
{
	LOG(NSLog(@"Removing Batch of Models"));
	for(NSString *key in modelKeys)	[self removeModelForKey:key];
}	


-(void)removeModelForKey:(NSString *)key
{
	//Should first check the retain count to ensure nobody else is referencing...
	NSUInteger rC = [[_modelPool objectForKey:key] retainCount];
	
	if(1!=rC){
		NSLog(@"ModelPool Object %@ Retained Elsewhere.  Count: %d", key, rC);
		[[_modelPool objectForKey:key] release];
		return;
	}
	LOG(NSLog(@"Removing Model:%@",key)); 
	[_modelPool removeObjectForKey:key];
}

-(vr3DModel *)objectForKey:(NSString *)key
{
	return [_modelPool objectForKey:key];
}

-(void)dealloc
{
	[_modelPool release];
	[super dealloc];
}


@end
