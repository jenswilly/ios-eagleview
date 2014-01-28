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

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_number = @( [[[element attributeForName:@"number"] stringValue] intValue] );
		_color = [EAGLELayer colorForColorString:[[element attributeForName:@"color"] stringValue]];	// Translate color index to color
		_visible = YES;	// All layers visible by default
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Layer %@: %@", self.number, self.name];
}

+ (UIColor*)colorForColorString:(NSString*)colorString
{
	// Convert to integer and swtich
	NSInteger color = [colorString intValue];

	switch( color )
	{
		case 1: // Busses: blue
			return RGB( 75, 75, 165 );
			
		case 2: // Nets
			return RGB( 75, 165, 75 );

		case 4:	// Symbols
			return RGB( 165, 75, 75 );

		case 7: // Values
			return RGB( 165, 165, 165 );

		default:
			return RGBHEX( 0x000000 );	// Default color is black
	}
}

@end
