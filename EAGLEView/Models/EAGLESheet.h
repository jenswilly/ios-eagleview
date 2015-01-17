//
//  EAGLESheet.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EAGLESchematic;
@class EAGLEPart;
@class DDXMLElement;
@class EAGLEModule;

@interface EAGLESheet : NSObject

@property (copy) NSString *name;
@property (readonly, strong) NSArray *instances;		// Sheet: Contains EAGLEInstance objects
@property (readonly, strong) NSArray *nets;				// Sheet: Contains EAGLENet objects
@property (readonly, strong) NSArray *busses;			// Sheet: NOTE: also contains EAGLENet objects since they are conceptually identical
@property (readonly, strong) NSArray *plainObjects;		// Contains id<EAGLEDrawable> objects. This represents "plain" objects like texts or lines
@property (readonly, strong) NSArray *moduleInstances;	// Contains EAGLEDrawableModuleInstance objects.
@property (readonly, strong) NSDictionary *drawablesInLayers;	// Layer number is key and the value is an NSArray of drawables
@property (readonly, strong) NSArray *orderedLayerKeys;
@property (readonly, strong) EAGLEModule *module;		// Parent module

- (id)initFromXMLElement:(DDXMLElement*)element schematic:(EAGLESchematic*)schematic module:(EAGLEModule*)module;

@end
