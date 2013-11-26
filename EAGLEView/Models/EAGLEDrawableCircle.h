//
//  EAGLECircle.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

@interface EAGLEDrawableCircle : EAGLEDrawableObject

@property (readonly) CGPoint center;
@property (readonly) CGFloat radius;
@property (readonly) CGFloat width;

@end
