//
//  EAGLESchematic.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLESchematic.h"
#import "DDXML.h"
#import "EAGLELibrary.h"
#import "EAGLELayer.h"
#import "EAGLEPart.h"
#import "EAGLEInstance.h"
#import "EAGLENet.h"
#import "EAGLEDrawableObject.h"
#import "EAGLESymbol.h"
#import "EAGLESheet.h"
#import "EAGLEModule.h"

@implementation EAGLESchematic

+ (instancetype)schematicFromSchematicAtPath:(NSString*)path error:(NSError *__autoreleasing *)error
{
	NSError *err = nil;
	NSURL *fileURL = [NSURL fileURLWithPath:path];
	NSData *xmlData = [NSData dataWithContentsOfURL:fileURL options:0 error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Get schematic
	NSArray *schematics = [xmlDocument nodesForXPath:@"/eagle/drawing/schematic" error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	EAGLESchematic *schematic = nil;
	if( [schematics count] > 0 )
		schematic = [[EAGLESchematic alloc] initFromXMLElement:schematics[ 0 ]];
	else
	{
		// Set reference to error
		*error = [NSError errorWithDomain:@"dk.greenerpastures.EAGLE" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"No schematic element found in file" }];
		return nil;
	}

	return schematic;
}

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error
{
	NSString *path = [[NSBundle mainBundle] pathForResource:schematicFileName ofType:@"sch"];
	return [self schematicFromSchematicAtPath:path error:error];
}

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super initFromXMLElement:element]) )
	{
		_currentModuleIndex = 0;	// Start at top-level module
		NSError *error = nil;

		// Modules. Start with top-level module
		NSMutableArray *tmpElements = [[NSMutableArray alloc] init];
		EAGLEModule *module = [[EAGLEModule alloc] initFromXMLElement:element schematic:self];
		if( module )
			[tmpElements addObject:module];

		// Other modules
		NSArray *elements = [element nodesForXPath:@"modules/module" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		for( DDXMLElement *childElement in elements )
		{
			EAGLEModule *object = [[EAGLEModule alloc] initFromXMLElement:childElement schematic:self];
			if( object )
				[tmpElements addObject:object];
		}

		_modules = [NSArray arrayWithArray:tmpElements];
	}

	return self;
}

- (EAGLEModule*)activeModule
{
	return self.modules[ _currentModuleIndex ];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Schematic: libraries: %@, parts: %@, %d instances, %d nets, %d busses", self.libraries, self.parts, (int)[self.instances count], (int)[self.nets count], (int)[self.busses count]];
}

#pragma mark - Proxy methods from current sheet
/* All these methods/properties are expected on an EAGLEFile object.
 * We simply call the corresponding method/property on the current sheet.
 */

- (EAGLEPart *)partWithName:(NSString *)name
{
	// Pass on to active module
	return [[self activeModule] partWithName:name];
}

- (NSArray *)parts
{
	return [self activeModule].parts;
}

- (NSArray *)instances
{
	return [self activeModule].activeSheet.instances;
}

- (NSArray *)nets
{
	return [self activeModule].activeSheet.nets;
}

- (NSArray *)busses
{
	return [self activeModule].activeSheet.busses;
}

- (NSArray *)plainObjects
{
	return [self activeModule].activeSheet.plainObjects;
}

- (NSDictionary *)drawablesInLayers
{
	return [self activeModule].activeSheet.drawablesInLayers;
}

- (NSArray *)orderedLayerKeys
{
	return [self activeModule].activeSheet.orderedLayerKeys;
}

@end
