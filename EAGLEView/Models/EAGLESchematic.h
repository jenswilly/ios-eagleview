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
@class EAGLENet;

@interface EAGLESchematic : EAGLEObject

@property (strong) NSDictionary *layers;
@property (readonly, strong) NSArray *libraries;
@property (readonly, strong) NSArray *parts;		// Contains EAGLEPart objects
@property (readonly, strong) NSArray *instances;	// Contains EAGLEInstance objects
@property (readonly, strong) NSArray *nets;			// Contains EAGLENet objects
@property (readonly, strong) NSArray *busses;		// NOTE: also contains EAGLENet objects since they are conceptually identical
@property (readonly, strong) NSArray *plainObjects;	// Contains id<EAGLEDrawable> objects. This represents "plain" objects like texts or lines

@property (copy) NSString *fileName;
@property (copy) NSDate *fileDate;

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;
+ (instancetype)schematicFromSchematicAtPath:(NSString*)path error:(NSError *__autoreleasing *)error;
- (EAGLEPart*)partWithName:(NSString*)name;
- (EAGLELibrary*)libraryWithName:(NSString*)name;
- (NSString*)dateString;

@end
