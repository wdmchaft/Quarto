//
//  qrScreen.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-30.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "vrUIElement.h"

@class qrViewController;

@interface qrScreen : NSObject {
	NSMutableArray		*_elements;
	qrViewController	*_viewController;
	
	NSString			*_backingTextureKey;
	CGRect				_bounds;
}

@property (nonatomic, readonly) NSMutableArray *elements;
@property (nonatomic, readonly) qrViewController *viewController;
@property (nonatomic, retain) NSString *backingTextureKey;

-(id)initWithController:(qrViewController *)viewController;
-(id)init;

-(void)renderFader:(float)c;

-(void)buttonBack:(id)sender;

-(void)drawView:(EAGLView *)view clear:(BOOL)clear;
-(void)drawView:(EAGLView *)view;

-(void)configureWithProperties:(NSDictionary *)properties;
-(void)loadUIElementsFromDictionary:(NSDictionary *)d;
-(void)setupUIElements;
-(vrUIElement *)elementWithKey:(NSString *)key;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView*)view; 

-(void)screenWillLoad;

@end
