//
//  EAGLELayer.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLELayer : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSNumber *number;
@property (readonly, strong) UIColor *color;
@property (assign) BOOL visible;

+ (UIColor*)colorForColorString:(NSString*)colorString;

@end
