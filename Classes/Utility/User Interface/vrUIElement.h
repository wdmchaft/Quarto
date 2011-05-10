//
//  vrUIElement.h
//  VectorRacer
//
//  Created by Jonathan Nobels on 09/04/09.
//  Copyright 2009 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Base Class for Non-Interactive Elements

@interface vrUIElement : NSObject {
	CGRect			_container;
	BOOL			_autoScale;
	int				_depth;
	NSString		*_key;
	
	BOOL			_hide;
}

@property (nonatomic) int depth;
@property (nonatomic, retain) NSString *key;
@property (nonatomic) BOOL hide;

-(id)initWithProperties:(NSDictionary *)properties;

-(void)render;

-(NSComparisonResult)sortByDepth:(vrUIElement *)element;

-(bool)checkDownTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;
-(bool)checkMoveTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;
-(bool)checkUpTouch:(UITouch*)touch event:(UIEvent *)event withView:(UIView*)view;

@end
