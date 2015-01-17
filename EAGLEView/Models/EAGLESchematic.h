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
@class EAGLEModule;

#define ORDERED_SCHEMATIC_LAYERS @[ @22, @24, @26, @28, @30, @32, @34, @36, @38, @40, @42, @52, @16, @1, @21, @23, @25, @27, @29, @31, @33, @35, @37, @39, @41, @51 ]

@interface EAGLESchematic : EAGLEFile

@property (readonly, strong) NSArray *parts;		// Schematic: Contains EAGLEPart objects
@property (readonly, strong) NSArray *instances;	// Schematic: Contains EAGLEInstance objects
@property (readonly, strong) NSArray *nets;			// Schematic: Contains EAGLENet objects
@property (readonly, strong) NSArray *busses;		// Schematic: NOTE: also contains EAGLENet objects since they are conceptually identical
@property (readonly, strong) NSArray *modules;		// EAGLEModule objects. Always contains at least one module which is the top-level schematic.

@property (assign) NSInteger currentModuleIndex;	/// TEMP: set active module

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;
+ (instancetype)schematicFromSchematicAtPath:(NSString*)path error:(NSError *__autoreleasing *)error;
- (EAGLEPart*)partWithName:(NSString*)name;
- (EAGLEModule*)activeModule;

@end
