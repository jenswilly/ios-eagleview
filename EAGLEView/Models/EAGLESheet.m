//
//  EAGLESheet.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLESheet.h"
#import "DDXML.h"
#import "EAGLEObject.h"
#import "EAGLEPart.h"
#import "EAGLEInstance.h"
#import "EAGLENet.h"
#import "EAGLEDrawableObject.h"
#import "EAGLESymbol.h"
#import "EAGLESchematic.h"
#import "EAGLEDrawableModuleInstance.h"

@implementation EAGLESheet

- (id)initFromXMLElement:(DDXMLElement*)element schematic:(EAGLESchematic*)schematic module:(EAGLEModule*)module
{
	if( (self = [super init] ))
	{
		NSError *error = nil;
		_module = module;

		// Instances
		NSArray *elements = [element nodesForXPath:@"instances/instance" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEInstance *instance = [[EAGLEInstance alloc] initFromXMLElement:childElement inFile:schematic module:_module];
			if( instance )
				[tmpElements addObject:instance];
		}
		_instances = [NSArray arrayWithArray:tmpElements];

		// Nets
		elements = [element nodesForXPath:@"nets/net" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLENet *net = [[EAGLENet alloc] initFromXMLElement:childElement inFile:schematic];
			if( net )
				[tmpElements addObject:net];
		}
		_nets = [NSArray arrayWithArray:tmpElements];

		// Busses
		elements = [element nodesForXPath:@"busses/bus" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLENet *net = [[EAGLENet alloc] initFromXMLElement:childElement inFile:schematic];
			if( net )
				[tmpElements addObject:net];
		}
		_busses = [NSArray arrayWithArray:tmpElements];

		// Plain
		elements = [element nodesForXPath:@"plain/*" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			// Drawable
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:schematic];
			if( drawable )
				[tmpElements addObject:drawable];
		}
		_plainObjects = [NSArray arrayWithArray:tmpElements];

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

		// Module instances. These do not have layer specified but are hardcoded to layer 90
		elements = [element nodesForXPath:@"moduleinsts/moduleinst" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			// Drawable
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:schematic];
			if( drawable )
				[tmpElements addObject:drawable];
		}
		if( [tmpElements count] > 0 )
		{
			_moduleInstances = [NSArray arrayWithArray:tmpElements];
			tmpDrawablesForLayers[ MODULE_INSTANCE_LAYER ] = _moduleInstances;
		}

		// Set dictionary of all drawables
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

@end
