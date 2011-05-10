//
//  qrBoardRenderer.m
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-23.
//  Copyright 2010 Barn*Star Studios. All rights reserved.
//

#import "qrBoardRenderer.h"
#import "glUtility.h"
#import "qrGeometryGlobals.h"
#import "vrAudioManager.h"

@implementation qrBoardRenderer

@synthesize rotationAngle = _zRot;
@synthesize boardState = _boardState;
@synthesize board = _board;


-(void)drawView:(EAGLView*)view
{
	gluSetDefault3DStates();
	[self setProjection:view];	
	
	[self drawBoard];
	[self drawPieces];
	
}

-(void)setProjection:(EAGLView *)view
{
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity();
	
	float s = ScreenScale();
	
	GLfloat zNear = Z_NEAR,zFar = Z_FAR;
	
	GLfloat size = zNear * tanf(DEG_TO_RAD(FIELD_OF_VIEW) / 2.0);
	GLfloat angle = 0;
	if([[qrGameState sharedqrGameState] screenFlipped])angle+=180;
	glRotatef(angle,0,0,-1);
	
	CGRect rect = view.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	//glViewport(0, rect.size.height*.1, rect.size.width, rect.size.height*.9);
	glViewport(0, 0, rect.size.width*s, rect.size.height*s);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	Vec3 cP = Vec3(0,-17,12);
	Vec3 cD = Vec3(0,1,-.56).normalize();
	Vec3 up1 = Vec3(0,0,1);
	
	Vec3 la = (cD - cP).normalize();
	
	Vec3 side = (up1.cross(la)).normalize();
	Vec3 up2 = la.cross(side);
	up2.normalize();
	
	gluLookAt(cP.x, cP.y,cP.z, cD.x, cD.y, cD.z, up2.x, up2.y, up2.z);
	glColor4f(1,1,1,1);
	Color3D c = Color3DMake(.6,.6,.6,1);

	gluAmbientLight(&c);
	glEnable(GL_LIGHT1);
	Vector3D lp = Vector3DMake(0,5,15);
	gluLightFromPoint(&lp, GL_LIGHT1);
	

	
	//zRot += .15;
	glTranslatef(3, 0, 0);
	glRotatef(_board.zRotation, 0, 0, 1);
	
	qrGeometryGlobals *gg = [qrGeometryGlobals sharedqrGeometryGlobals];
	[gg saveMVPMatrices];
}

-(void)drawBoard
{
	vrModelPool *modelPool = [vrModelPool sharedvrModelPool];
	//TODO: Pull this from the board...
	vr3DModel *board = [modelPool objectForKey:@"board"];
	[board drawSelf];
	
}

-(void)drawPieces
{
	float x = -6, dx = 4;
	float y = -6, dy = 4;
	int *winPositions = NULL;
	float scale = .8;
	float rot;
	Color3D c;
	_pieceRotation += 5;
	
	if(_boardState.gameOver){
		if(_boardState.winningPlayer != 2) winPositions = [_boardState winPositions];
	}
	
	for(unsigned char i =0;i<16;i++){
		qrPiece *p = [_boardState pieceAtPosition:i];
		if(p){
			if(winPositions){
				for(int j=0;j<4;j++){
					if(winPositions[j] == i){
						scale = .9;
						c = Color3DMake(1,.6,.6,1);
						rot = _pieceRotation;
					}
				}
			}
			glPushMatrix();
			glTranslatef(x,y,0);
			
			if(p.placeAnimation){
				BOOL animating = [p.placeAnimation updateAnimation];
				[p.placeAnimation translateAndScale];
				if(!animating){
					LOG(NSLog(@"Finishing Animation for %@",[p fileNameFromProperties]));
					PostNotification(@"PieceAnimationComplete");
					p.placeAnimation = nil;
					vrAudioManager *am = [vrAudioManager sharedvrAudioManager];
					[am playUISoundWithKey:@"Place"];
				}
			}
			
			glScalef(scale, scale, scale);
			glRotatef(rot, 0, 0, 1);
			glColor4f(c.red,c.green,c.blue,c.alpha);
			[p.model drawSelf];
			glPopMatrix();
			scale = .8;
			c = Color3DMake(1,1,1,1);
			rot = 0;
		}
		x+=dx; 
		if(x>6){
			x=-6; y+=dy;
		}
	}
	glColor4f(c.red,c.green,c.blue,c.alpha);
}

-(void)drawTest
{
	vrModelPool *modelPool = [vrModelPool sharedvrModelPool];
	NSString *zero = [[NSString alloc] initWithString:@"0"];
	NSString *one  = [[NSString alloc] initWithString:@"1"];
	
	float x = -6, dx = 4;
	float y = -6, dy = 4;
	

	
	for(unsigned char i =0;i<16;i++){
		NSMutableString *fName = [[NSMutableString alloc] init];
		[fName appendFormat:@"p"];
		for (unsigned char z = 8; z > 0; z >>= 1)
			(i & z)	? [fName appendString:one] : [fName appendString:zero];
		
		vr3DModel *model = [modelPool objectForKey:fName];
		
		glPushMatrix();
		glTranslatef(x,y,0);
		[model drawSelf];
		glPopMatrix();
		
		x+=dx; 
		if(x>6){
			x=-6; y+=dy;
		}
		[fName release];
	}
	
	//[_board debugDrawRay];
	
	[one release];
	[zero release];
}


@end
