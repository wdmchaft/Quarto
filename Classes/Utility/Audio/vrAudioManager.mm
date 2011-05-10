//
//  vrAudioManager.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 04/05/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrAudioManager.h"
#import "qrGameState.h"

@implementation vrAudioManager

SYNTHESIZE_SINGLETON_FOR_CLASS(vrAudioManager)


-(bool)loadUIEffectList:(NSString *)plist{
	NSString *effectsDictionaryPath	= [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
	NSDictionary *effectsDictionary	= [[NSDictionary alloc] initWithContentsOfFile:effectsDictionaryPath];
	
	if(_uiEffects)[_uiEffects release];
	_uiEffects = [[NSMutableDictionary alloc] init];
	
	for(NSString *effectName in effectsDictionary)
	{
		NSString *fname = [effectsDictionary objectForKey:effectName];
		NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:nil];
		
		if(path){
			SoundEffect *effect = [[SoundEffect alloc] initWithContentsOfFile:path];
			if(effect)[_uiEffects setObject:effect forKey:effectName];
			[effect release];
			//NSLog(@"Loaded UI Effect File %@ With Key %@",fname,effectName);
		}
		else{
			NSLog(@"UI Effect With Key: %@ File Not Found",fname);
		}
		
	}
	
	[effectsDictionary release];
	return TRUE;
}


-(bool)playUISoundWithKey:(NSString *)key
{
	if(!_uiEffects){
		NSLog(@"UIEffects List Not Loaded");
		return false;
	}
	
	qrGameState *gs = [qrGameState sharedqrGameState];
	if(gs.muted)return 0;
	
	SoundEffect *effect = [_uiEffects objectForKey:key];
	
	if(!effect){
		NSLog(@"Sound For Key: %@ not found in UI Effects List",key);
	}
	[effect play];
	return true;
}


-(void)dealloc
{
	[_uiEffects				release];
	[super dealloc];
	
}

@end
