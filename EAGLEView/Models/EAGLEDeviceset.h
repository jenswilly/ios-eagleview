//
//  EAGLEDeviceset.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
@class EAGLEGate;

@interface EAGLEDeviceset : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *gates;	// Contains EAGLEGate objects
@property (readonly, strong) NSArray *devices;	// Contains EAGLEDevice objects

- (EAGLEGate*)gateWithName:(NSString*)name;

@end
