//
//  EAGLESchematic.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLESchematic : EAGLEObject

@property (strong) NSDictionary *layers;
@property (readonly, strong) NSArray *libraries;
@property (readonly, strong) NSArray *parts;

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;

@end
