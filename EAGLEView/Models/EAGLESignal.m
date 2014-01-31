//
//  EAGLESignal.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLESignal.h"
#import "EAGLEDrawableVia.h"
#import "EAGLEDrawablePolygon.h"
#import "DDXML.h"

@implementation EAGLESignal

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		NSError *error = nil;
		NSArray *elements = [element nodesForXPath:@"wire" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:file];
			if( drawable )
				[tmpElements addObject:drawable];
		}
		_wires = [NSArray arrayWithArray:tmpElements];

		// Get vias
		elements = [element nodesForXPath:@"via" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEDrawableVia *via = [[EAGLEDrawableVia alloc] initFromXMLElement:childElement inFile:file];
			if( via )
				[tmpElements addObject:via];
		}
		_vias = [NSArray arrayWithArray:tmpElements];

		// Get vias
		elements = [element nodesForXPath:@"polygon" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEDrawablePolygon *polygon = [[EAGLEDrawablePolygon alloc] initFromXMLElement:childElement inFile:file];
			if( polygon )
				[tmpElements addObject:polygon];
		}
		_polygons = [NSArray arrayWithArray:tmpElements];
}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Signal %@ - %d wires, %d vias", _name, (int)[_wires count], (int)[_vias count]];
}

- (void)drawInContext:(CGContextRef)context
{
	// Filter wires if there is a filter predicate
	NSArray *activeWires;
	if( self.filterPredicateForDrawing )
		activeWires = [self.wires filteredArrayUsingPredicate:self.filterPredicateForDrawing];
	else
		activeWires = self.wires;

	for( EAGLEDrawableObject *drawable in activeWires )
		[drawable drawInContext:context];

	for( id<EAGLEDrawable> drawable in self.vias )
		[drawable drawInContext:context];

//	for( id<EAGLEDrawable> drawable in self.polygons )
//		[drawable drawInContext:context];
}

- (CGFloat)maxX
{
	CGFloat maxX = -MAXFLOAT;

	for( id<EAGLEDrawable> wire in self.wires )
		maxX = MAX( maxX, [wire maxX] );

	// And vias
	for( EAGLEDrawableVia *via in self.vias )
		maxX = MAX( maxX, [via maxX] );

	return maxX;
}

- (CGFloat)maxY
{
	CGFloat maxY = -MAXFLOAT;

	for( id<EAGLEDrawable> wire in self.wires )
		maxY = MAX( maxY, [wire maxY] );

	// And vias
	for( EAGLEDrawableVia *via in self.vias )
		maxY = MAX( maxY, [via maxY] );

	return maxY;
}

- (CGFloat)minX
{
	CGFloat minX = MAXFLOAT;

	for( id<EAGLEDrawable> wire in self.wires )
		minX = MIN( minX, [wire minX] );

	// And vias
	for( EAGLEDrawableVia *via in self.vias )
		minX = MIN( minX, [via minX] );

	return minX;
}

- (CGFloat)minY
{
	CGFloat minY = MAXFLOAT;

	for( id<EAGLEDrawable> wire in self.wires )
		minY = MIN( minY, [wire minY] );

	// And vias
	for( EAGLEDrawableVia *via in self.vias )
		minY = MIN( minY, [via minY] );

	return minY;
}

- (CGPoint)origin
{
	return CGPointMake( ([self maxX] - [self minX]) / 2, ([self maxY] - [self minY]) / 2 );
}

- (CGRect)boundingRect
{
	/// TODO
	return CGRectZero;
}

@end
