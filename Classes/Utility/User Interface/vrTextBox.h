//
//  vrTextBox.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 02/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "glTextManager.h"
#import	"vrUIElement.h"
#import "Texture2D.h"
#import "vrTexturePool.h"


@interface vrTextBox : vrUIElement {
	NSString		*_label;
	float			_labelScale;
	Texture2D		*_backingTexture;
	Texture2D		*_overlayTexture;
	NSString		*_backingTextureKey;
	NSString		*_overlayTextureKey;
	
	BOOL			_centerText;
	
	CGRect			containerRect;
	ControlRect		_cR;
	
	Vector3D		_angles;
	Vector3D		_rotation;
	Vector3D		_translation;
	
}

@property (nonatomic,retain) NSString* label;

-(id)initWithProperties:(NSDictionary *)properties;

-(void)setTexture:(NSString*)key;
-(void)setAngles:(Vector3D)angles;
-(void)setTranslation:(Vector3D)translation;
-(void)setContainerRect:(CGRect)r;
-(void)rotateBy:(Vector3D)rotation;
-(void)pushTransform;
-(void)renderWithJitter:(int)jitter;


@end
