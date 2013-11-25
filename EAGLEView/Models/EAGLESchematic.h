//
//  EAGLESchematic.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
@class EAGLEPart;
@class EAGLELibrary;

@interface EAGLESchematic : EAGLEObject

@property (strong) NSDictionary *layers;
@property (readonly, strong) NSArray *libraries;
@property (readonly, strong) NSArray *parts;		// Contains EAGLEPart objects
@property (readonly, strong) NSArray *instances;	// Contains EAGLEInstance objects

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;
- (EAGLEPart*)partWithName:(NSString*)name;
- (EAGLELibrary*)libraryWithName:(NSString*)name;

@end
