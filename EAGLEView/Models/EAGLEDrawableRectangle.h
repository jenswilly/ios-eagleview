//
//  EAGLEDrawableRectangle.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

@interface EAGLEDrawableRectangle : EAGLEDrawableObject

@property (readonly) CGPoint point1;
@property (readonly) CGPoint point2;
@property (readonly) CGFloat width;

@end
