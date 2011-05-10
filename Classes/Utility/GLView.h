//
//  GLView.h
//  Convenience Class to fire up an EAGL view.


//ControlTouch Actions
#define CT_DOWN  0x01
#define CT_UP	 0x02
#define CT_MOVED 0x03




#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@protocol GLViewDelegate;
@protocol controlTouchDelegate;

@interface GLView : UIView
{
	@private

	GLint				backingWidth;
	GLint				backingHeight;
	
	EAGLContext			*context;
	GLuint				viewRenderbuffer;
	GLuint				viewRenderbuffer2;
	GLuint				viewFramebuffer;
	GLuint				depthRenderbuffer;
	NSTimer				*animationTimer;
	NSTimeInterval		animationInterval;
	
	GLuint				readyRenderBuffer;
	GLuint				workingRenderBuffer;
	
	bool				rb1rendering;
	bool				rb2rendering;
	
	bool				rb1displayed;
	bool				rb2displayed;
	
	id<GLViewDelegate>  delegate;
	BOOL				delegateSetup;
	
	id<controlTouchDelegate> cTDelegate;
	
	CGRect				viewPort;
}

//@property(nonatomic, assign) id<GLViewDelegate> delegate;

@property NSTimeInterval animationInterval;

-(void)drawView;
-(void)drawToBackBuffer;
-(void)presentRenderbuffer;



- (id)initGLES;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setControlTouchDelegate:(id<controlTouchDelegate>)d;
- (void)setRenderDelegate:(id<GLViewDelegate>)d;


@end




@protocol controlTouchDelegate<NSObject>
	@required
	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
	- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view;
	- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
@end


@protocol GLViewDelegate<NSObject>
	@required
		-(void)drawView:(GLView*)view;
	@optional
		-(void)setupView:(GLView*)view;
@end