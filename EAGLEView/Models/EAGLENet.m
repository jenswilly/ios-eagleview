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
			EAGLEDrawableWire *wire = [[EAGLEDrawableWire alloc] initFromXMLElement:childElement inSchematic:schematic];
			if( wire )
				[tmpWires addObject:wire];
		}
		_wires = [NSArray arrayWithArray:tmpWires];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Net %@ – %d wires", self.name, [self.wires count]];
}

- (void)drawInContext:(CGContextRef)context
{
	// Iterate and draw all wires
	for( EAGLEDrawableWire *wire in self.wires )
		[wire drawInContext:context];
}

@end
