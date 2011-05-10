//
//  vrTextBox.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 02/10/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "vrTextBox.h"
#import "NSString+vectorParse.h"
#import "vrTypeDefs.h"

@implementation vrTextBox

@synthesize label = _label;

-(id)initWithProperties:(NSDictionary *)properties{
	self = [super initWithProperties:properties];
	if(self){
		if([properties objectForKey:@"controlRect"]){
			_cR = [[properties objectForKey:@"controlRect"] controlRectFromCDS];
		}
		if([properties objectForKey:@"labelScale"]){
			_labelScale	= [[properties objectForKey:@"labelScale"] floatValue];
		}
		else {
			_labelScale = 1;
		}
		if([properties objectForKey:@"label"]){
			_label = [[properties objectForKey:@"label"] retain];
		}
		if([properties objectForKey:@"backingTexture"]){
			_backingTextureKey = [[NSString alloc] initWithString:[properties objectForKey:@"backingTexture"]];
		}
		if([properties objectForKey:@"overlayTexture"]){
			_overlayTextureKey = [[NSString alloc] initWithString:[properties objectForKey:@"overlayTexture"]];
		}
		if([properties objectForKey:@"centerText"]){
			_centerText = [[properties objectForKey:@"centerText"] boolValue];
		}else{
			_centerText = YES;
		}
		
		

			//_labelColor = Color3DMake(0,.8,0,1);
		if(_autoScale){
			CGRect bounds = ScaledBounds();
			_cR.top *= bounds.size.height/480.0f;
			_cR.bottom *= bounds.size.height/480.0f;
			_cR.left *= bounds.size.width/320.0f;
			_cR.right *= bounds.size.width/320.0f;
		}
		containerRect = CGRectFromControlRect(_cR);
		//[self setRects];
	}
	return self;
}

-(void)setContainerRect:(CGRect)r
{
	containerRect = r;
	if(_autoScale){
		iPadScaleRect(&containerRect);
	}
}

-(void)setTexture:(NSString*)key
{
	_backingTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:key];
}


-(void)setAngles:(Vector3D)angles
{
	_angles=angles;
}

-(void)setTranslation:(Vector3D)translation
{
	_translation = translation;
}

-(void)rotateBy:(Vector3D)rotation
{
	_angles = Vector3DAdd(_angles,rotation);
	//NSLog(@"Angles: %f",_angles.z);
}


-(void)pushTransform
{
	glTranslatef(_translation.x, _translation.y, _translation.z);
	glRotatef(_angles.y,0,1,0);
	glRotatef(_angles.z,0,0,1);
}

-(void)renderWithJitter:(int)jitter
{
	
	float j = randomf()*jitter;
	
	float k = _translation.x;
	_translation.x = j;
	
	glTextManager *tM = [glTextManager sharedTextManager];
	
	if(_overlayTextureKey)_overlayTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_overlayTextureKey];
	if(_backingTextureKey)_backingTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_backingTextureKey];
		
	glPushMatrix();
	[self pushTransform];
	
	glColor4f(1,1,1,1);
	if(_backingTexture)[_backingTexture drawInRect:containerRect depth:-1.9f];
	if(_label)[tM renderCharacterString:_label inRect:containerRect];
	
	glPopMatrix();
	
	_translation.x = k;
}

-(void)render
{
	//NSLog(@"Render Text Box");
	glPushMatrix();
	[self pushTransform];
	
	if(_overlayTextureKey)_overlayTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_overlayTextureKey];
	if(_backingTextureKey)_backingTexture = [[vrTexturePool sharedvrTexturePool] objectForKey:_backingTextureKey];
		
	vrFontPerfs fp;
	fp.color = Color3DMake(.95,.95,.95,1);
	fp.shadowOffset = 2;
	fp.centered = _centerText;
	fp.scale = NO;
	fp.rect = scaleRect(containerRect, _labelScale);
	
	glTextManager *tM = [glTextManager sharedTextManager];
	
	glColor4f(1,1,1,1);
	if(_backingTexture)[_backingTexture drawInRect:containerRect depth:-1.9f];
	if(_overlayTexture)[_overlayTexture drawInRect:containerRect depth:-1.9f];
	if(_label){
		//[_tM renderCharacterStringScaled:_label inRect:containerRect withShadowOffset:2 centered:true];
		[tM renderCharacterString:_label withOptions:&fp];
	}
	glPopMatrix();
}

-(void)dealloc
{
	[_label release];
	[_backingTextureKey release];
	[_overlayTextureKey release];
	[super dealloc];
}

@end
