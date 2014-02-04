//
//  EAGLEFile.h
//  
//
//  Created by Jens Willy Johannsen on 27/01/14.
//
//

#import "EAGLEObject.h"
@class EAGLELibrary;

#define TOP_LAYERS    @[  @1, @21, @23, @25, @27, @29, @31, @33, @35, @37, @39, @41, @51 ]
#define BOTTOM_LAYERS @[ @16, @22, @24, @26, @28, @30, @32, @34, @36, @38, @40, @42, @52 ]

@interface EAGLEFile : EAGLEObject
{
	NSArray *_libraries;
	NSArray *_plainObjects;
	NSDictionary *_drawablesInLayers;
	NSArray *_orderedLayerKeys;
}

@property (strong) NSDictionary *layers;
@property (readonly, strong) NSArray *libraries;
@property (readonly, strong) NSArray *plainObjects;	// Contains id<EAGLEDrawable> objects. This represents "plain" objects like texts or lines
@property (copy) NSString *fileName;
@property (copy) NSDate *fileDate;
@property (readonly, strong) NSDictionary *drawablesInLayers;	// Layer number is key and the value is an NSArray of drawables
@property (readonly, strong) NSArray *orderedLayerKeys;

- (EAGLELibrary*)libraryWithName:(NSString*)name;
- (NSString*)dateString;
- (BOOL)allTopLayersVisible;
- (BOOL)allBottomLayersVisible;

@end
