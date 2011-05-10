//
//  ESRenderer.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol RenderDelegate<NSObject>
-(void)drawView:(id)sender;
@end

@protocol ESRenderer <NSObject>
- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)setRenderDelegate:(id<RenderDelegate>)delegate;
@end




