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

@interface EAGLELibrary : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *symbols;
@property (readonly, strong) NSArray *devicesets;

- (EAGLEDeviceset*)devicesetWithName:(NSString*)name;
- (EAGLESymbol*)symbolWithName:(NSString*)name;

@end
