//
//  EAGLEInstance.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
@class EAGLESymbol;

@interface EAGLEInstance : EAGLEObject

@property (readonly, strong) NSString *part_name;
@property (readonly, strong) NSString *gate_name;
@property (readonly) CGPoint point;
@property (readonly) BOOL smashed;
@property (readonly) CGFloat rotation;

- (EAGLESymbol*)symbol;
- (void)drawInContext:(CGContextRef)context;

@end
