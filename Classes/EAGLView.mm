//
//  EAGLView.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright Barn*Star Studios 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
#import "ES2Renderer.h"

//#import "glUtility.h"

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		if([[UIScreen mainScreen] respondsToSelector: NSSelectorFromString(@"scale")])
		{
			if([self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")])
			{
				[self setContentScaleFactor:[[UIScreen mainScreen] scale]];
				//self.contentScaleFactor = 1.0f;
			}
		}		
		
		// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
										nil];
		
		// Create our EAGLContext, and if successful make it current and create our framebuffer.
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFrameBuffer])
		{
			[self release];
			return nil;
		}
		
	    animating = FALSE;
        displayLinkSupported = TRUE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
		
		/*
		float scale = 1;
		if([[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")]){
			UIScreen *screen = [UIScreen mainScreen];
			scale = screen.scale;
		}
		
		CGRect bounds = [[UIScreen mainScreen] bounds];
		self.bounds = CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width*scale,bounds.size.height*scale);
		*/
   }
   return self;
}


- (BOOL)createFrameBuffer
{
	if(viewFramebuffer || viewRenderbuffer || depthRenderbuffer){
		//NSLog(@"Frame Buffers Already Created.  Aborting");
		return YES;
	}
	// Generate IDs for a framebuffer object and a color renderbuffer
	[EAGLContext setCurrentContext:context];
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
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	//NSLog(@"Destroying Frame & Render Buffers....");
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


-(void)setDelegate:(id<GLViewDelegate>)delegate
{
	renderDelegate = delegate;
}

-(void)setTouchDelegate:(id<TouchDelegate>)delegate
{
	touchDelegate = delegate;
}


- (void)drawView:(id)sender
{
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	if(renderDelegate)[renderDelegate drawView:self];
}

- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFrameBuffer];
    [self drawView:self];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink setFrameInterval:animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		//LOG(NSLog(@"Starting Animation With Interval %d",animationFrameInterval));
		animating = YES;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
		[displayLink invalidate];
		displayLink = nil;
		animating = NO;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:self];	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchDelegate	touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:self];
}	


- (void)dealloc
{
    [super dealloc];
}

@end
