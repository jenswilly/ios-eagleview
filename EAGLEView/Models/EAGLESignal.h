//
//  EAGLESignal.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"

@interface EAGLESignal : EAGLEObject <EAGLEDrawable>

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *wires;	// Contains EAGLEDrawableWire og -Arc objects
@property (readonly, strong) NSArray *vias;		// Contains EAGLEDrawableVia objects
@property (readonly, strong) NSArray *polygons;	// Contains EAGLEDrawablePolygon objects

@property (strong) NSPredicate *filterPredicateForDrawing;

@end
