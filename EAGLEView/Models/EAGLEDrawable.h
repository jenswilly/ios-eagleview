//
//  EAGLEDrawable.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLEDrawable : EAGLEObject

@property (nonatomic, readonly) NSNumber *layerNumber;

+ (EAGLEDrawable*)drawableFromXMLElement:(DDXMLElement*)element inSchematic:(EAGLESchematic*)schematic;
- (void)drawInContext:(CGContextRef)context;

@end
