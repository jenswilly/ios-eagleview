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
#import "EAGLEDeviceset.h"
#import "EAGLEPackage.h"

@implementation EAGLELibrary

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		// Name
		_name = [[element attributeForName:@"name"] stringValue];

		// Symbols
		NSError *error = nil;
		NSArray *symbols = [element nodesForXPath:@"symbols/symbol" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[symbols count]];
		for( DDXMLElement *childElement in symbols )
		{
			EAGLESymbol *symbol = [[EAGLESymbol alloc] initFromXMLElement:childElement inFile:file];
			if( symbol )
				[tmpArray addObject:symbol];
		}
		_symbols = [NSArray arrayWithArray:tmpArray];

		// Devicesets
		NSArray *devicesets = [element nodesForXPath:@"devicesets/deviceset" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		tmpArray = [[NSMutableArray alloc] initWithCapacity:[devicesets count]];
		for( DDXMLElement *childElement in devicesets )
		{
			// Deviceset
			EAGLEDeviceset *deviceset = [[EAGLEDeviceset alloc] initFromXMLElement:childElement inFile:file];
			if( deviceset )
				[tmpArray addObject:deviceset];
		}
		_devicesets = [NSArray arrayWithArray:tmpArray];

		// Packages
		NSArray *packages = [element nodesForXPath:@"packages/package" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpArray = [[NSMutableArray alloc] initWithCapacity:[devicesets count]];
		for( DDXMLElement *childElement in packages )
		{
			// Package
			EAGLEPackage *package = [[EAGLEPackage alloc] initFromXMLElement:childElement inFile:file];
			if( package )
				[tmpArray addObject:package];
		}
		_packages = [NSArray arrayWithArray:tmpArray];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Library %@ - %d symbols, %d devicesets, %d packages", self.name, (int)[self.symbols count], (int)[self.devicesets count], (int)[self.packages count]];
}

- (EAGLEDeviceset *)devicesetWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.devicesets filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

- (EAGLESymbol *)symbolWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.symbols filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

- (EAGLEPackage*)packageWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.packages filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}
@end
