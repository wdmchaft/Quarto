//
//  qrScreen.mm
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrScreen.h"
#import "qrViewController.h"
#import "vrTexturePool.h"

@implementation qrScreen

@synthesize elements = _elements;
@synthesize viewController = _viewController;
@synthesize backingTextureKey = _backingTextureKey;

-(id)init
{
	return [self initWithController:nil];
}

-(id)initWithController:(qrViewController *)viewController
{
	self = [super init];
	if(self){
		_elements = [[NSMutableArray alloc] init];
		_viewController = viewController;
	}
	return self;
}

-(void)dealloc
{
	[_elements release];
	[super dealloc];
}

-(void)buttonBack:(id)sender
{
	[self.viewController setActiveScreenWithKey:@"HomeScreen" withTransition:kFadeIn];
}

-(void)renderFader:(float)c
{

	CGRect bounds = ScaledBounds();
	GLfloat fadeRect[] = {0,0,-1.9,bounds.size.width,0,-1.9,0,bounds.size.height,-1.9,bounds.size.width,bounds.size.height,-1.9};
	glColor4f(0,0,0,1-c);	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(3, GL_FLOAT, 0, fadeRect);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}


-(void)drawView:(EAGLView *)view clear:(BOOL)clear
{
	glColor4f(1,1,1,1);

	if(clear){
		glClearColor(0.2f, 0.2f, 0.2f, 1.0f); 
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	}
	
	if(self.backingTextureKey){
		Texture2D *t = [[vrTexturePool sharedvrTexturePool] objectForKey:self.backingTextureKey];
		[t drawInRect:ScaledBounds()];
	}
	
	for(vrUIElement *e in _elements)if(!e.hide)[e render];
}

-(void)drawView:(EAGLView *)view
{
	[self drawView:view clear:YES];
}

-(void)configureWithProperties:(NSDictionary *)properties
{
	if([properties objectForKey:@"backingTexture"]){
		self.backingTextureKey = [properties objectForKey:@"backingTexture"];
	}
	return;
}

-(void)loadUIElementsFromDictionary:(NSDictionary *)d
{
	for(NSString *elementKey in d){
		//NSLog(@"   Creating Element: %@",elementKey);
		NSDictionary *elementDef = [d objectForKey:elementKey];
		NSString *elementClass = [elementDef objectForKey:@"class"];
		
		if(!elementClass){
			//NSLog(@"Error: No Class Found For %@",elementKey);
			continue;
		}
		
		id element = [[NSClassFromString(elementClass) alloc] initWithProperties:elementDef];
		
		if([element isKindOfClass:NSClassFromString(@"vrUIElement")])
		{
			[element performSelector:@selector(initWithProperties:) withObject:elementDef];
		}else{
			NSLog(@"Error: %@ Does Not Inherit from vrUIElement",elementClass);
			[element release];
			continue;
		}
		
		if([element respondsToSelector:@selector(setTarget:)]){
			[element performSelector:@selector(setTarget:) withObject:self];
		}
		
		[_elements addObject:element];
		[element setKey:elementKey];
		[element release];
	}
	//NSLog(@"Added %d Elements to %@",[_elements count],[self class]);
	[_elements sortUsingSelector:@selector(sortByDepth:)];
}

-(void)setupUIElements
{
	return;
}


-(vrUIElement *)elementWithKey:(NSString *)key
{
	for(vrUIElement *element in _elements){
		if([element.key isEqualToString:key])return element;
	}
	return nil;	
}


-(void)screenWillLoad
{
	return;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	UITouch *touch = [touches anyObject];
	CGPoint t = [touch locationInView:view];
	bool	  _hit = false;
	
	for(vrUIElement *e in _elements)
	{
		if(!e.hide)_hit = [e checkDownTouch:touch event:event withView:view];
		if(_hit)break;
	}	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view{

	
	UITouch *touch = [touches anyObject];
	CGPoint t = [touch locationInView:view];
	bool	  _hit = false;
	
	for(vrUIElement *e in _elements)
	{
		if(!e.hide)_hit = [e checkMoveTouch:touch event:event withView:view];
		if(_hit)break;
	}	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view
{
	UITouch *touch = [touches anyObject];
	CGPoint t = [touch locationInView:view];
	bool	  _hit = false;
	
	for(vrUIElement *e in _elements)
	{
		if(!e.hide)_hit = [e checkUpTouch:touch event:event withView:view];
		if(_hit)break;
	}	
}   

@end
