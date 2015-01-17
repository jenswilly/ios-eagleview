//
//  EAGLEModule.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLEModule.h"
#import "DDXML.h"
#import "EAGLESchematic.h"
#import "EAGLESheet.h"
#import "EAGLEPart.h"

@implementation EAGLEModule

- (id)initFromXMLElement:(DDXMLElement*)element schematic:(EAGLESchematic*)schematic
{
	if( (self = [super init] ))
	{
		NSError *error = nil;

		// Set name from "name" property. If might still be nil though.
		_name = [[element attributeForName:@"name"] stringValue];

		// Parts
		NSArray *elements = [element nodesForXPath:@"parts/part" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLEPart *object = [[EAGLEPart alloc] initFromXMLElement:childElement inFile:schematic];
			if( object )
				[tmpElements addObject:object];
		}
		_parts = [NSArray arrayWithArray:tmpElements];

		// Sheets
		elements = [element nodesForXPath:@"sheets/sheet" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLESheet *object = [[EAGLESheet alloc] initFromXMLElement:childElement schematic:schematic module:self];
			if( object )
				[tmpElements addObject:object];
		}
		_sheets = [NSArray arrayWithArray:tmpElements];
		DEBUG_LOG( @"Loaded %d sheet(s) in module '%@'.", (int)[_sheets count], self.name );

	}
	return self;
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

- (EAGLESheet *)activeSheet
{
	/// TEMP: use first sheet as active sheet
	return [self.sheets firstObject];
}

@end
