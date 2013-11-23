//
//  EAGLELayer.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLELayer.h"
#import "DDXML.h"

@implementation EAGLELayer

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_number = @( [[[element attributeForName:@"number"] stringValue] intValue] );
		_color = [EAGLELayer colorForColorString:[[element attributeForName:@"color"] stringValue]];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Layer %@: %@", self.number, self.name];
}

/*
+ (NSArray *)layersFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error
{
	// Open file
	NSError *err = nil;
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:schematicFileName withExtension:@"sch"];
	NSData *xmlData = [NSData dataWithContentsOfURL:fileURL options:0 error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Read XML
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Select layers
	NSArray *layers = [xmlDocument nodesForXPath:@"/eagle/drawing/layers/layer" error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Iterate and initialize objects
	NSMutableArray *tmpLayers = [[NSMutableArray alloc] initWithCapacity:[layers count]];
	for( DDXMLElement *element in layers )
	{
		EAGLELayer *layer = [[EAGLELayer alloc] initFromXMLElement:element];
		if( layer )
			[tmpLayers addObject:layer];
	}

	return [NSArray arrayWithArray:tmpLayers];
}
*/

+ (UIColor*)colorForColorString:(NSString*)colorString
{
	// Convert to integer and swtich
	NSInteger color = [colorString intValue];

	switch( color )
	{
		case 4:	// Symbols
			return RGB( 165, 75, 75 );

		case 7: // Values
			return RGB( 165, 165, 165 );

		default:
			return RGBHEX( 0x000000 );	// Default color is black
	}
}

@end
