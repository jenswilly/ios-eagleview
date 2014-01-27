//
//  EAGLEPackage.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"

@interface EAGLEPackage : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *components;

- (void)drawInContext:(CGContextRef)context;
- (CGFloat)maxX;
- (CGFloat)maxY;
- (CGFloat)minX;
- (CGFloat)minY;

@end
