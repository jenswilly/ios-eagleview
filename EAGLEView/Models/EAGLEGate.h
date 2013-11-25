//
//  EAGLEGate.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLEGate : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSString *symbol_name;
@property (readonly) CGPoint point;

@end
