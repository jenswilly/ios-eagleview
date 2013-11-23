//
//  EAGLEObject.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Abstract base object for all EAGLE objects.
 */
@interface EAGLEObject : NSObject

//- (id)initFromXMLFragment:(id)xmlFragment;
//- (id)xmlFragment;

+ (NSArray *)layersFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error;

@end
