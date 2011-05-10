//
//  glTextManager.mm
//  VectorRacer
//
//  Created by Jonathan Nobels on 02/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import "glTextManager.h"



@implementation glTextManager

static glTextManager *sharedTextManager = nil;

+(glTextManager *)sharedTextManager
{ 
	//@synchronized(self) 
	//{ 
		if (sharedTextManager == nil)
		{ 
			sharedTextManager = [[glTextManager alloc] init]; 
		} 
	//} 
	return sharedTextManager;
} 

-(id)init
{
	self = [super init];
	if(self){
		_renderStateSet	= false;
		_font = [[vrFont alloc] initWithFontDef:DEFAULT_FONT_DEF withTexture:DEFAULT_FONT_MAP];
	}
	else {
		NSLog(@"Default glTextManager Initialization Failed");
	}
	
	return self;
}


-(id)initWithFont:(NSString *)name
{	
	//self = [super init];
	self = nil;
	if(self){
		_stringCount	= 0;
		_renderStateSet	= false;
	}
	else {
		NSLog(@"Custom glTextManager Initialization Failed");
	}
	return self;
}




-(void)renderCharacterStringScaled:(NSString *)string withOptions:(vrFontPerfs*)p
{
	float w = p->rect.size.width;
	p->rect.size.width *= kTextScaleFactor;
#if GLTM_SHADOW	
	if(p->shadowOffset){
		CGRect offsetRect = CGRectOffset(p->rect, p->shadowOffset, p->shadowOffset);
		glColor4f(kTextDSColour);
		[_font renderString:string inRect:offsetRect centered:p->centered];
	}
#endif
	
	glColor4f(p->color.red,p->color.green,p->color.blue,p->color.alpha);
	[_font renderString:string inRect:p->rect centered:p->centered];
	p->rect.size.width = w;
}

-(void)renderCharacterString:(NSString *)string withOptions:(vrFontPerfs*)p
{
	if(p->scale){
		CGRect bounds = ScaledBounds();
		p->rect.origin.x *= bounds.size.width/320.0f;
		p->rect.origin.y *= bounds.size.height/480.0f;
		p->rect.size.width *= kTextScaleFactor*bounds.size.width/320.0f;
		p->rect.size.height *= bounds.size.height/480.0f;
	}
#if GLTM_SHADOW	
	if(p->shadowOffset){
		CGRect offsetRect = CGRectOffset(p->rect, p->shadowOffset, p->shadowOffset);
		glColor4f(kTextDSColour);
		[_font renderString:string inRect:offsetRect centered:p->centered];
	}
#endif	
	glColor4f(p->color.red,p->color.green,p->color.blue,p->color.alpha);
	[_font renderString:string inRect:p->rect centered:p->centered];
}

-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset
{
	[self renderCharacterString:string inRect:rect withShadowOffset:offset centered:false];
}

-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset centered:(bool)centered
{
	/*
	CGRect bounds = [[UIScreen mainScreen] bounds];
	rect.origin.x *= bounds.size.width/320.0f;
	rect.origin.y *= bounds.size.height/480.0f;
	rect.size.width *= kTextScaleFactor*bounds.size.width/320.0f;
	rect.size.height *= bounds.size.height/480.0f;
	*/
	//if(bounds.size.width/320.0f > 1)rect.size.width *= .9;
#if GLTM_SHADOW	
	CGRect offsetRect = CGRectOffset(rect, 2, 2);
	glColor4f(kTextDSColour);
	[_font renderString:string inRect:offsetRect centered:centered];
#endif
	glColor4f(kTextDefaultColour);
	[_font renderString:string inRect:rect centered:centered];
}

-(void)renderCharacterStringScaled:(NSString *)string inRect:(CGRect)rect withShadowOffset:(int)offset centered:(bool)centered
{
	rect.size.width *= kTextScaleFactor;
	CGRect offsetRect = CGRectOffset(rect, 2, 2);
#if GLTM_SHADOW	
	glColor4f(kTextDSColour);
	[_font renderString:string inRect:offsetRect centered:centered];
#endif	
	glColor4f(kTextDefaultColour);
	[_font renderString:string inRect:rect centered:centered];
}


-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect
{
	[self renderCharacterString:string inRect:rect centered:false];
}


-(void)renderCharacterString:(NSString *)string inRect:(CGRect)rect centered:(bool)centered

{
	/*
	CGRect bounds = [[UIScreen mainScreen] bounds];
	rect.origin.x *= bounds.size.width/320.0f;
	rect.origin.y *= bounds.size.height/480.0f;
	rect.size.width *= kTextScaleFactor*bounds.size.width/320.0f;
	rect.size.height *= bounds.size.height/480.0f;
	if(bounds.size.width/320.0f > 1)rect.size.width *= .9;
	*/
	
	[_font renderString:string inRect:rect];
	return;
}

-(void)renderTimeInterval:(NSTimeInterval)interval inRect:(CGRect)rect withPrefix:(NSString*)prefix
{
	double time = interval;
	int seconds = (int)time % 60;
	int minutes	= (int)time/60;
	int tenths	= 10*(double)(time - (int)time);
	
	NSString *timeString = [[NSString alloc] initWithFormat:@"%@%02d:%02d.%d",prefix,minutes,seconds,tenths];
	[self renderCharacterString:timeString inRect:rect];
	[timeString release];
}	

//Set up our rendering states and surface once, then render a bunch of shit.

-(void)enableTextRenderStates:(Color3D)color
{
	//glColor4f(color.red,color.green,color.blue,color.alpha);
	_renderStateSet = true;
}


//After rendering a bunch of shit - disable the states
-(void)disableTextRenderStates {
	_renderStateSet = false;
}

-(void)dealloc {
	[super dealloc];
}

@end
