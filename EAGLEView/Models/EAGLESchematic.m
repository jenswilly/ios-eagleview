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

	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Get schematic
	NSArray *schematics = [xmlDocument nodesForXPath:@"/eagle/drawing/schematic" error:error];
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
		if( error )
			*error = [NSError errorWithDomain:@"dk.greenerpastures.EAGLE" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"No schematic element found in file" }];
		return nil;
	}

	// Get layers
	NSArray *layers = [xmlDocument nodesForXPath:@"/eagle/drawing/layers/layer[ @active=\"yes\" ]" error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Iterate and initialize objects
	NSMutableDictionary *tmpLayers = [[NSMutableDictionary alloc] initWithCapacity:[layers count]];
	for( DDXMLElement *element in layers )
	{
		EAGLELayer *layer = [[EAGLELayer alloc] initFromXMLElement:element inFile:schematic];
		if( layer )
			tmpLayers[ layer.number ] = layer;
	}
	schematic.layers = [NSDictionary dictionaryWithDictionary:tmpLayers];

	return schematic;
}

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error
{
	NSString *path = [[NSBundle mainBundle] pathForResource:schematicFileName ofType:@"sch"];
	return [self schematicFromSchematicAtPath:path error:error];
}

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super init]) )
	{
		NSError *error = nil;

		// Libraries
		NSArray *elements = [element nodesForXPath:@"libraries/library" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		// Iterate and initialize objects
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLELibrary *library = [[EAGLELibrary alloc] initFromXMLElement:childElement inFile:self];
			if( library )
				[tmpElements addObject:library];
		}
		_libraries = [NSArray arrayWithArray:tmpElements];

		// Parts
		elements = [element nodesForXPath:@"parts/part" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEPart *part = [[EAGLEPart alloc] initFromXMLElement:childElement inFile:self];
			if( part )
				[tmpElements addObject:part];
		}
		_parts = [NSArray arrayWithArray:tmpElements];

		// Instances
		elements = [element nodesForXPath:@"sheets/sheet/instances/instance" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEInstance *instance = [[EAGLEInstance alloc] initFromXMLElement:childElement inFile:self];
			if( instance )
				[tmpElements addObject:instance];
		}
		_instances = [NSArray arrayWithArray:tmpElements];

		// Nets
		elements = [element nodesForXPath:@"sheets/sheet/nets/net" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLENet *net = [[EAGLENet alloc] initFromXMLElement:childElement inFile:self];
			if( net )
				[tmpElements addObject:net];
		}
		_nets = [NSArray arrayWithArray:tmpElements];
		// Nets
		elements = [element nodesForXPath:@"sheets/sheet/nets/net" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLENet *net = [[EAGLENet alloc] initFromXMLElement:childElement inFile:self];
			if( net )
				[tmpElements addObject:net];
		}
		_nets = [NSArray arrayWithArray:tmpElements];

		// Busses
		elements = [element nodesForXPath:@"sheets/sheet/busses/bus" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLENet *net = [[EAGLENet alloc] initFromXMLElement:childElement inFile:self];
			if( net )
				[tmpElements addObject:net];
		}
		_busses = [NSArray arrayWithArray:tmpElements];

		// Plain
		elements = [element nodesForXPath:@"sheets/sheet/plain/*" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			// Drawable
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:self];
			if( drawable )
				[tmpElements addObject:drawable];
		}
		_plainObjects = [NSArray arrayWithArray:tmpElements];

}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Schematic: libraries: %@, parts: %@, %d instances, %d nets, %d busses", self.libraries, self.parts, (int)[self.instances count], (int)[self.nets count], (int)[self.busses count]];
}

- (EAGLEPart *)partWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.parts filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

@end
