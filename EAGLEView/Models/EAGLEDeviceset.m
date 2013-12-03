//
//  EAGLEDeviceset.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDeviceset.h"
#import "DDXML.h"
#import "EAGLEGate.h"

@implementation EAGLEDeviceset

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_prefix = [[element attributeForName:@"prefix"] stringValue];

		// Gates
		NSError *error = nil;
		NSArray *gates = [element nodesForXPath:@"gates/gate" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpGates = [[NSMutableArray alloc] initWithCapacity:[gates count]];
		for( DDXMLElement *childElement in gates )
		{
			EAGLEGate *gate = [[EAGLEGate alloc] initFromXMLElement:childElement inSchematic:schematic];
			if( gate )
				[tmpGates addObject:gate];
		}
		_gates = [NSArray arrayWithArray:tmpGates];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Deviceset %@ – %d gates, %d devices", self.name, (int)[self.gates count], (int)[self.devices count]];
}

- (EAGLEGate *)gateWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.gates filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}
@end
