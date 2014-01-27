//
//  EAGLELibrary.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
@class EAGLEDeviceset;
@class EAGLESymbol;
@class EAGLEPackage;

@interface EAGLELibrary : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *symbols;
@property (readonly, strong) NSArray *devicesets;
@property (readonly, strong) NSArray *packages;

- (EAGLEDeviceset*)devicesetWithName:(NSString*)name;
- (EAGLESymbol*)symbolWithName:(NSString*)name;
- (EAGLEPackage*)packageWithName:(NSString *)name;

@end
