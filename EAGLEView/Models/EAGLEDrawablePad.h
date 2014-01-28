//
//  EAGLEDrawablePad.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"

@interface EAGLEDrawablePad : EAGLEDrawableObject

@property (readonly) CGFloat drill;
@property (readonly) CGFloat diameter;
@property (readonly) CGPoint point;
@property (readonly) Rotation rotation;

@end
