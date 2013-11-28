//
//  EAGLEDrawable.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@protocol EAGLEDrawable <NSObject>

- (void)drawInContext:(CGContextRef)context;
- (CGFloat)maxX;
- (CGFloat)maxY;

@end

@interface EAGLEDrawableObject : EAGLEObject  <EAGLEDrawable>

@property (nonatomic, readonly) NSNumber *layerNumber;

+ (EAGLEDrawableObject*)drawableFromXMLElement:(DDXMLElement*)element inSchematic:(EAGLESchematic*)schematic;
- (void)drawInContext:(CGContextRef)context;

- (void)setStrokeColorFromLayerInContext:(CGContextRef)context;
- (void)setFillColorFromLayerInContext:(CGContextRef)context;

@end
