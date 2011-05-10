//
//  EAGLView.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright Barn*Star Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@protocol GLViewDelegate;
@protocol TouchDelegate;


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;

    id displayLink;
    NSTimer *animationTimer;
	
	EAGLContext			*context;
	
	GLint				backingWidth;
	GLint				backingHeight;
	
	GLuint				viewRenderbuffer;
	GLuint				viewFramebuffer;
	GLuint				depthRenderbuffer;
	
	id<GLViewDelegate>	renderDelegate;
	id<TouchDelegate>	touchDelegate;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

-(BOOL)createFrameBuffer;
-(void)destroyFramebuffer;

-(void)setDelegate:(id<GLViewDelegate>)delegate;
-(void)setTouchDelegate:(id<TouchDelegate>)delegate;


- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end


@protocol GLViewDelegate<NSObject>
-(void)drawView:(EAGLView*)view;
@end

@protocol TouchDelegate<NSObject>
@required
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
@end

