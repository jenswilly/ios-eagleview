//
//  EAGLEElement.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"
@class EAGLEPackage;

@interface EAGLEElement : EAGLEObject <EAGLEDrawable>

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSString *value;
@property (readonly) CGPoint point;
@property (readonly) BOOL smashed;
@property (readonly) Rotation rotation;
@property (readonly, strong) NSString *library_name;
@property (readonly, strong) EAGLEPackage *package;
@property (readonly, strong) NSDictionary *smashedAttributes;

- (void)drawInContext:(CGContextRef)context layerNumber:(NSNumber*)layerNumber;

@end
