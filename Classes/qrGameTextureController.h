//
//  qrGameTextureController.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-29.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vrTexturePool.h"

@interface qrGameTextureController : NSObject {
	NSMutableDictionary		*_loadedTextures;
	BOOL					_texturesLoaded;
}

-(id)init;
-(void)loadTexturesFromPlist:(NSString *)plist;
-(void)freeAllTextureMemory;
-(void)restoreTextures;

@end
