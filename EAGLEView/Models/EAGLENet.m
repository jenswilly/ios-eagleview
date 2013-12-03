//
//  EAGLENet.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLENet.h"
#import "DDXML.h"
#import "EAGLEDrawableWire.h"
#import "EAGLEDrawableText.h"
#import "EAGLEDrawableJunction.h"

@implementation EAGLENet

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		NSError *error = nil;
		NSArray *wires = [element nodesForXPath:@"segment/wire" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpWires = [[NSMutableArray alloc] initWithCapacity:[wires count]];
		for( DDXMLElement *childElement in wires )
		{
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inSchematic:schematic];
			if( drawable )
				[tmpWires addObject:drawable];
		}
		_wires = [NSArray arrayWithArray:tmpWires];

		// Get labels
		NSArray *elements = [element nodesForXPath:@"segment/label" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEDrawableText *label = [[EAGLEDrawableText alloc] initFromXMLElement:childElement inSchematic:schematic];
			if( label )
			{
				// Set text to the name of the bus
				label.valueText = _name;
				[tmpElements addObject:label];
			}
		}
		_labels = [NSArray arrayWithArray:tmpElements];

		// Junctions
		elements = [element nodesForXPath:@"segment/junction" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEDrawableJunction *junction = [[EAGLEDrawableJunction alloc] initFromXMLElement:childElement inSchematic:schematic];
			if( junction )
				[tmpElements addObject:junction];
		}
		_junctions = [NSArray arrayWithArray:tmpElements];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Net %@ – %d wires, %d labels", self.name, [self.wires count], [self.labels count]];
}

- (void)drawInContext:(CGContextRef)context
{
	// Iterate and draw all wires
	for( EAGLEDrawableWire *wire in self.wires )
		[wire drawInContext:context];

	// And texts
	for( EAGLEDrawableText *label in self.labels )
		[label drawInContext:context];

	// And junctions
	for( EAGLEDrawableJunction *junction in self.junctions )
		[junction drawInContext:context];
}

- (CGFloat)maxX
{
	CGFloat maxX = -MAXFLOAT;

	for( EAGLEDrawableWire *wire in self.wires )
		maxX = MAX( maxX, [wire maxX] );

	// And texts
	for( EAGLEDrawableText *label in self.labels )
		maxX = MAX( maxX, [label maxX] );

	// And junctions
	for( EAGLEDrawableJunction *junction in self.junctions )
		maxX = MAX( maxX, [junction maxX] );

	return maxX;
}

- (CGFloat)maxY
{
	CGFloat maxY = -MAXFLOAT;

	for( EAGLEDrawableWire *wire in self.wires )
		maxY = MAX( maxY, [wire maxY] );

	// And texts
	for( EAGLEDrawableText *label in self.labels )
		maxY = MAX( maxY, [label maxY] );

	// And junctions
	for( EAGLEDrawableJunction *junction in self.junctions )
		maxY = MAX( maxY, [junction maxY] );

	return maxY;
}

- (CGFloat)minX
{
	CGFloat minX = MAXFLOAT;

	for( EAGLEDrawableWire *wire in self.wires )
		minX = MIN( minX, [wire minX] );

	// And texts
	for( EAGLEDrawableText *label in self.labels )
		minX = MIN( minX, [label minX] );

	// And junctions
	for( EAGLEDrawableJunction *junction in self.junctions )
		minX = MIN( minX, [junction minX] );

	return minX;
}

- (CGFloat)minY
{
	CGFloat minY = MAXFLOAT;

	for( EAGLEDrawableWire *wire in self.wires )
		minY = MIN( minY, [wire minY] );

	// And texts
	for( EAGLEDrawableText *label in self.labels )
		minY = MIN( minY, [label minY] );

	// And junctions
	for( EAGLEDrawableJunction *junction in self.junctions )
		minY = MIN( minY, [junction minY] );

	return minY;
}

@end
