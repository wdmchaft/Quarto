//
//  qrInstructionsScreen.h
//  Quarto
//
//  Created by Jonathan Nobels on 10-10-09.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qrScreen.h"
#import "vrButton.h"
#import "vrModalDialog.h"

@interface qrInstructionsScreen : vrModalDialog {
	NSMutableArray		*_pages;
	int					_currentPage;
}

-(void)nextPage:(vrButton *)sender;

@end
