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

#define ORDERED_SCHEMATIC_LAYERS @[ @22, @24, @26, @28, @30, @32, @34, @36, @38, @40, @42, @52, @16, @1, @21, @23, @25, @27, @29, @31, @33, @35, @37, @39, @41, @51 ]

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
		NSError *error = nil;

		// Parts
		NSArray *elements = [element nodesForXPath:@"parts/part" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
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


		///
		// Extract drawables for each layer
		NSMutableDictionary *tmpDrawablesForLayers = [NSMutableDictionary dictionary];

		for( int layer = 0; layer < 255; layer++ )
		{
			BOOL hasInstanceDrawables = NO;

			NSMutableArray *tmpDrawablesForLayer = [NSMutableArray array];
			NSPredicate *layerPredicate = [NSPredicate predicateWithFormat:@"layerNumber = %@", @( layer )];

			// Nets contain wires, labels and junctions
			for( EAGLENet *net in _nets )
			{
				[tmpDrawablesForLayer addObjectsFromArray:[net.wires filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[net.junctions filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[net.labels filteredArrayUsingPredicate:layerPredicate]];
			}

			// Busses are also nets and contain wires, labels and junctions
			for( EAGLENet *bus in _busses )
			{
				[tmpDrawablesForLayer addObjectsFromArray:[bus.wires filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[bus.junctions filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[bus.labels filteredArrayUsingPredicate:layerPredicate]];
			}

			// Instances
			for( EAGLEInstance *instance in _instances )
			{
				// If any instance has components or smashed attributes on this layer we'll set the Boolean so we are sure to add an entry in the dictionary so we know what layer are "active"

				if( [[instance.symbol.components filteredArrayUsingPredicate:layerPredicate] count] > 0 ||
				   [[[instance.smashedAttributes allValues] filteredArrayUsingPredicate:layerPredicate] count] > 0 )
					hasInstanceDrawables = YES;
			}

			// Plain objects
			[tmpDrawablesForLayer addObjectsFromArray:[_plainObjects filteredArrayUsingPredicate:layerPredicate]];

			// Add objects if there are any (no need to have a bunch of empty arrays)
			if( [tmpDrawablesForLayer count] > 0 || hasInstanceDrawables )
				tmpDrawablesForLayers[ @(layer) ] = [NSArray arrayWithArray:tmpDrawablesForLayer];
		}
		_drawablesInLayers = [NSDictionary dictionaryWithDictionary:tmpDrawablesForLayers];

		// Sort layer keys. The .orderedLayerKeys now contains an ordered list of used layer numbers.
		NSArray *keysForOrdering = ORDERED_SCHEMATIC_LAYERS;	// First bottom layers, then top layers
		_orderedLayerKeys = [[_drawablesInLayers allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

			// If obj1 < obj2, then ascending
			if( [keysForOrdering indexOfObject:obj1] < [keysForOrdering indexOfObject:obj2] )
				return NSOrderedAscending;
			else
				return NSOrderedDescending;
		}];
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
