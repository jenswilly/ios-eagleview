//
//  EAGLEDrawable.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLELayer.h"
#import "EAGLEFile.h"

#define RETURN_IF_NOT_LAYER_VISIBLE if( !((EAGLELayer*)self.file.layers[ self.layerNumber ]).visible ) return

@protocol EAGLEDrawable <NSObject>

- (void)drawInContext:(CGContextRef)context;
- (CGFloat)maxX;
- (CGFloat)maxY;
- (CGFloat)minX;
- (CGFloat)minY;
- (CGPoint)origin;
- (CGRect)boundingRect;

@end

typedef enum
{
	Rotation_0,
	Rotation_R45,
	Rotation_R90,
	Rotation_R180,
	Rotation_R225,
	Rotation_R270,
	Rotation_Mirror_MR0
} Rotation;

@interface EAGLEDrawableObject : EAGLEObject  <EAGLEDrawable>
{
	NSNumber *_layerNumber;
}

@property (nonatomic, readonly) NSNumber *layerNumber;

+ (EAGLEDrawableObject*)drawableFromXMLElement:(DDXMLElement*)element inFile:(EAGLEFile*)file;
- (void)drawInContext:(CGContextRef)context;

- (void)setStrokeColorFromLayerInContext:(CGContextRef)context;
- (void)setFillColorFromLayerInContext:(CGContextRef)context;
+ (CGFloat)radiansForRotation:(Rotation)rotation;
+ (Rotation)rotationForString:(NSString*)rotationString;

@end
