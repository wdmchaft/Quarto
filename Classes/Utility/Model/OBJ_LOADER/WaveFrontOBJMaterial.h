//
//  WaveFrontOBJMaterial.h

#import <Foundation/Foundation.h>
#import "WaveFrontOBJTypes.h"

@class WaveFrontOBJTexture;

@interface WaveFrontOBJMaterial : NSObject {
	NSString *name;
	NSString *fileName;
	// color and illumination
	ColorRGBA ambientColor; // Ka ambient reflectivity
	ColorRGBA diffuseColor; // Kd diffuse reflectivity
	ColorRGBA specularColor; // Ks specular reflectivity
	ColorRGBA transmittedColor; // Tf the color transmitted through the material
	
	GLfloat shine; // Ns, specular exponent
	GLuint illumination; // illum, the illumination model defined by wave front, eventually a shader?
	GLfloat disolve; // d the transparency of the material, with the halo option is inverted == 1.0 - (N*v)(1.0-factor)
	GLfloat sharpness; // sharpness of reflections, 1 to 1000
	GLfloat refractionIndex; // Ni, the refraction index of the material

	// textue map
	WaveFrontOBJTexture *ambientTexture;
	WaveFrontOBJTexture *diffuseTexture;
	WaveFrontOBJTexture *specularTexture;
	WaveFrontOBJTexture *shineTexture;
	WaveFrontOBJTexture *disolveTexture;
	WaveFrontOBJTexture *displacementTexture;
	WaveFrontOBJTexture *decalTexture;
	WaveFrontOBJTexture *bumpTexture;
	// reflection map - not implemented
	
	//Dictionary to store keyed texture maps
	NSMutableDictionary	*textures;
	
	
}
@property(retain) NSString *name;
@property(assign) ColorRGBA ambientColor;
@property(assign) ColorRGBA diffuseColor;
@property(assign) ColorRGBA specularColor;
@property(assign) ColorRGBA transmittedColor;
@property(assign) GLfloat shine;
@property(assign) GLuint illumination;
@property(assign) GLfloat disolve;
@property(assign) GLfloat sharpness;
@property(assign) GLfloat refractionIndex;


+ (NSArray *)materialsFromLibraryFile:(NSString *)fileName;
- (GLuint)textureIDForKey:(NSString *)key;
- (WaveFrontOBJTexture*)textureForKey:(NSString *)key;
- (NSMutableDictionary *)textures;
- (GLuint)textureName;
- (NSString*)textureFile;


/*
@property(retain) WaveFrontOBJTexture *ambientTexture;
@property(retain) WaveFrontOBJTexture *diffuseTexture;
@property(retain) WaveFrontOBJTexture *specularTexture;
@property(retain) WaveFrontOBJTexture *shineTexture;
@property(retain) WaveFrontOBJTexture *disolveTexture;
@property(retain) WaveFrontOBJTexture *displacementTexture;
@property(retain) WaveFrontOBJTexture *decalTexture;
@property(retain) WaveFrontOBJTexture *bumpTexture;
*/
@end
