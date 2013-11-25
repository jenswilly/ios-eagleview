//
//  EAGLEPart.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLEPart : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSString *value;
@property (readonly, strong) NSString *library_name;
@property (readonly, strong) NSString *deviceset_name;
@property (readonly, strong) NSString *device_name;

@end
