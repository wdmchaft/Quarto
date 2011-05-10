//
//  vrAudioManager.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 04/05/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "vrConstants.h"
#import "SoundEffect.h"
#import <AVFoundation/AVAudioPlayer.h>


/*******************************************
/* vrAudioManager wraps the file handling functios of the SoundEngine Library
/*		This lets us load and reference sound effects using shared pList files.
/*
/*	Generally, to fart around pitch, location, etc - use getSoundIDForKey: to retrieve the
/*  effectID to use with the SoundEngine class.
/* 
/*  Some utiltity functions are provided 
/*******************************************/


//For effects - we can have multiple simultaneous libraries.  Each can be allocated and deallocated
//as required.  Pass the following constants for the withLib: parameter
#define kUIEffectsLib			0
#define kGameSharedEffectsLib	1
#define kGameCustomEffectsLib	2

#define	kMaxEffectLibs			3

@interface vrAudioManager : NSObject <AVAudioPlayerDelegate> {
	NSMutableDictionary		*_uiEffects;

}


+(vrAudioManager*)sharedvrAudioManager;

//UI SoundEffect Support... Yet another type of sound effect!
-(bool)loadUIEffectList:(NSString *)plist;
-(bool)playUISoundWithKey:(NSString *)key;


@end
