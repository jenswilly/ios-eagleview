//
//  EAGLESchematic.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEFile.h"
@class EAGLEPart;
@class EAGLELibrary;
@class EAGLENet;


@interface EAGLESchematic : EAGLEFile

@property (readonly, strong) NSArray *parts;		// Schematic: Contains EAGLEPart objects
@property (readonly, strong) NSArray *instances;	// Schematic: Contains EAGLEInstance objects
@property (readonly, strong) NSArray *nets;			// Schematic: Contains EAGLENet objects
@property (readonly, strong) NSArray *busses;		// Schematic: NOTE: also contains EAGLENet objects since they are conceptually identical

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;
+ (instancetype)schematicFromSchematicAtPath:(NSString*)path error:(NSError *__autoreleasing *)error;
- (EAGLEPart*)partWithName:(NSString*)name;

@end
