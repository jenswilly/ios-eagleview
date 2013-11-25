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

@implementation EAGLESchematic

+ (instancetype)schematicFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error
{
	NSError *err = nil;
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:schematicFileName withExtension:@"sch"];
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
	NSArray *layers = [xmlDocument nodesForXPath:@"/eagle/drawing/layers/layer" error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Iterate and initialize objects
	NSMutableDictionary *tmpLayers = [[NSMutableDictionary alloc] initWithCapacity:[layers count]];
	for( DDXMLElement *element in layers )
	{
		EAGLELayer *layer = [[EAGLELayer alloc] initFromXMLElement:element inSchematic:schematic];
		if( layer )
			tmpLayers[ layer.number ] = layer;
	}
	schematic.layers = [NSDictionary dictionaryWithDictionary:tmpLayers];

	return schematic;
}

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super init]) )
	{
		NSError *error = nil;

		// Libraries
		NSArray *libraries = [element nodesForXPath:@"libraries/library" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		// Iterate and initialize objects
		NSMutableArray *tmpLibraries = [[NSMutableArray alloc] initWithCapacity:[libraries count]];
		for( DDXMLElement *libraryElement in libraries )
		{
			EAGLELibrary *library = [[EAGLELibrary alloc] initFromXMLElement:libraryElement inSchematic:self];
			if( library )
				[tmpLibraries addObject:library];
		}
		_libraries = [NSArray arrayWithArray:tmpLibraries];

		// Parts
		NSArray *parts = [element nodesForXPath:@"parts/part" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpParts = [[NSMutableArray alloc] initWithCapacity:[parts count]];
		for( DDXMLElement *childElement in parts )
		{
			EAGLEPart *part = [[EAGLEPart alloc] initFromXMLElement:childElement inSchematic:self];
			if( part )
				[tmpParts addObject:part];
		}
		_parts = [NSArray arrayWithArray:tmpParts];

		// Instances
		NSArray *instances = [element nodesForXPath:@"sheets/sheet/instances/instance" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpInstances = [[NSMutableArray alloc] initWithCapacity:[instances count]];
		for( DDXMLElement *childElement in instances )
		{
			EAGLEInstance *instance = [[EAGLEInstance alloc] initFromXMLElement:childElement inSchematic:self];
			if( instance )
				[tmpInstances addObject:instance];
		}
		_instances = [NSArray arrayWithArray:tmpInstances];
}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Schematic: libraries: %@, parts: %@, %d instances", self.libraries, self.parts, [self.instances count]];
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

- (EAGLELibrary *)libraryWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.libraries filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

@end
