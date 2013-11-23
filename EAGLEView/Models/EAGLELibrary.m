//
//  EAGLELibrary.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLELibrary.h"
#import "DDXML.h"
#import "EAGLESymbol.h"

@implementation EAGLELibrary

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		// Name
		_name = [[element attributeForName:@"name"] stringValue];

		// Symbols
		NSError *error = nil;
		NSArray *symbols = [element nodesForXPath:@"symbols/symbol" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpSymbols = [[NSMutableArray alloc] initWithCapacity:[symbols count]];
		for( DDXMLElement *childElement in symbols )
		{
			EAGLESymbol *symbol = [[EAGLESymbol alloc] initFromXMLElement:childElement inSchematic:schematic];
			if( symbol )
				[tmpSymbols addObject:symbol];
		}
		_symbols = [NSArray arrayWithArray:tmpSymbols];

		// ...

		// Devicesets
		NSArray *devicesets = [element nodesForXPath:@"devicesets/deviceset" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpDevicesets = [[NSMutableArray alloc] initWithCapacity:[devicesets count]];
		for( DDXMLElement *childElement in devicesets )
		{
			// Deviceset
			// ...
		}
		_devicesets = [NSArray arrayWithArray:tmpDevicesets];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Library %@, symbols: %@, %d devicesets", self.name, self.symbols, [self.devicesets count]];
}

@end
