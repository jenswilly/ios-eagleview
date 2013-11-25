//
//  EAGLEInstance.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"
@class EAGLESymbol;

@interface EAGLEInstance : EAGLEObject <EAGLEDrawable>

@property (readonly, strong) NSString *part_name;
@property (readonly, strong) NSString *gate_name;
@property (readonly) CGPoint point;
@property (readonly) BOOL smashed;
@property (readonly) CGFloat rotation;

- (EAGLESymbol*)symbol;

@end
