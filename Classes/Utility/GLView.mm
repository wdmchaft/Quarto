//
//  GLView.m
//  NeHe Lesson 02
//
//  Created by Jeff LaMarche on 12/11/08.
//  Copyright Jeff LaMarche Consulting 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"


@implementation GLView

@synthesize animationInterval;


+ (Class) layerClass
{
	return [CAEAGLLayer class];
}


-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		self = [self initGLES];
		[self setMultipleTouchEnabled:YES];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder]))
	{
		self = [self initGLES];
		[self setMultipleTouchEnabled:YES];
	}	
	return self;
}

-(id)initGLES
{
	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	
	// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
										nil];
	
	// Create our EAGLContext, and if successful make it current and create our framebuffer.
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer])
	{
		[self release];
		return nil;
	}
	
	animationInterval = 1.0 / 60.0;
	return self;
}

-(id<GLViewDelegate>)delegate
{
	return delegate;
}

// Update the delegate, and if it needs a -setupView: call, set our internal flag so that it will be called.
-(void)setRenderDelegate:(id<GLViewDelegate>)d
{
	delegate = d;
	delegateSetup = ![delegate respondsToSelector:@selector(setupView:)];
}

-(void)setControlTouchDelegate:(id<controlTouchDelegate>)d
{
	cTDelegate = d;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	//[EAGLContext setCurrentContext:context];
	//[self destroyFramebuffer];
	//[self createFramebuffer];
	//[self drawView];
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen whereever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT24_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);

	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	glFinish();
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

-(void)presentRenderbuffer
{
	[EAGLContext setCurrentContext:context];
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, readyRenderBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
}

// Updates the OpenGL view when the timer fires
- (void)drawView
{
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	// If our drawing delegate needs to have the view setup, then call -setupView: and flag that it won't need to be called again.
	if(!delegateSetup)
	{
		[delegate setupView:self];
		delegateSetup = YES;
	}
	else{
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, readyRenderBuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	[delegate drawView:self];
	
	
	
	//GLenum err = glGetError();
	//if(err)
	//	NSLog(@"%x error", err);
}

-(void)drawToBackBuffer
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	[delegate drawView:self];
}
	
	
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[cTDelegate touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[cTDelegate touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:self];	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[cTDelegate	touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:self];
}	

// Stop animating and release resources when they are no longer needed.
- (void)dealloc
{
	
	if([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
