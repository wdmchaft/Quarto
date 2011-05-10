/*
 *  vrConstants.h
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 07/03/09.
 *  Copyright 2009 Barn*Star Studios. All rights reserved.
 *
 */

//Last Version - 10
#define CH_VERSION					12

#define kLiteVersion				1
#define isHD						0

#define CHEATS_ACTIVE				0

#define	PERF_LOG					0				//Set to 1 to enable performance logging
#define VERBOSE_LOGGING				0

#define COMMENT SLASH(/)
#define SLASH(s) /##s


#if VERBOSE_LOGGING
	#define LOG(__LOGMSG__)				__LOGMSG__
	#define qrLOG(__LOGMSG__)			__LOGMSG__
	#define WARN(__LOGMSG__)			__LOGMSG__
#else
	#define LOG(__LOGMSG__)				if(0)__LOGMSG__
	#define qrLOG(__LOGMSG__)			if(0)__LOGMSG__
	#define WARN(__LOGMSG__)			if(1)__LOGMSG__
#endif

//#define	ENABLE_FOG					0

//Must be a factor of 60... 60,30,20, etc...
#define FRAME_RATE					30.0f
#define kHighDetailFrameRate		30.0f
#define kLowDetailFrameRate			30.0f

#define kMaxLowDetailProjectiles    24

#define kDefaultAtlas				@"ModelAtlas_theme1.png.pvrtc"


#define USETIMER					0
#define USEDISPLAYLINK				1

#define kUSEVRM						1

#define	kLowDetailMeshLimit			12
#define kHighDetailMeshLimit		22
#define kMaxDetailMeshLimit			28

#define kLowDetailPolyLimit			3000
#define kHighDetailPolyLimit		6000

//Default Field of View Angles
#define FIELD_OF_VIEW				60.0f
#define SKYBOX_DEPTH				1000.0f

//Default Camera Postion
#define CAM_DISTANCE				8.7f
#define CAM_HEIGHT					6.0f
#define CAM_ANGLE					23.0f

#define Z_FAR						400
#define Z_NEAR						4


//Speeds are define as meters per frame *30 for m/s
#define kMinSpeed					9
#define kMaxSpeed					19
#define	kSpeedFactor				40

//70 for iPad Builds
#define	kVPBar						0

#define kFiringConstant				14000.0f

//Default Camera Settings  - Angle,Height,Distance
#define CAM_HOVER					11.6,6.2,11.3
#define CAM_FOLLOW					7.4,3.8,8.2
#define CAM_COCKPIT					0,2.5,0

#define kTextDefaultColour			.95,.95,.95,1
#define kTextModalColour			.92,.92,.92,1
#define kTextDSColour				.1,.1,.1,.8

#define kTextCol2					kTextDefaultColour

#define kTiltFactor					70.0f

#define kShieldMin					50.0f

#define RACER_HEIGHT				.75f

//NOTE: World Objects are create at the origin and then translated... This requires
//      the world to extend slightly into negative XY space.

#define	WORLD_ORIGIN_X				-100
#define WORLD_ORIGIN_Y				-100
#define WORLD_SIZE_X				3000
#define WORLD_SIZE_Y				3000

#define	WORLD_MID_X					((WORLD_ORIGIN_X+WORLD_SIZE_X)/2)
#define WORLD_MID_Y					((WORLD_ORIGIN_Y+WORLD_SIZE_Y)/2)

#define WORLD_HX					WORLD_SIZE_X/2
#define WORLD_HY					WORLD_SIZE_Y/2

#define GRID_SPACING				25

