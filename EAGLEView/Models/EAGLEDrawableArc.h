//
//  EAGLEDrawableArc.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

@interface EAGLEDrawableArc : EAGLEDrawableObject

@property (readonly) CGPoint point1;
@property (readonly) CGPoint point2;
@property (readonly) CGFloat width;
@property (readonly) CGFloat curve;		// Curve amount in degrees. Negative numbers are clockwise; positive are counter-clockwise.

@end
