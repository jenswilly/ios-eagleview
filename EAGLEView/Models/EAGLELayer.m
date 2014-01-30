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
{
	UIColor *_color;
}

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_number = @( [[[element attributeForName:@"number"] stringValue] intValue] );
		_fillPatternNumber = @( [[[element attributeForName:@"fill"] stringValue] intValue] );
		_color = [EAGLELayer colorForColorString:[[element attributeForName:@"color"] stringValue]];	// Translate color index to color
		_visible = YES;	// All layers visible by default
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Layer %@: %@, visible: %d", self.number, self.name, self.visible];
}

- (UIColor *)color
{
	if( [_color isEqual:RGBHEX( 0x000000 )] )
		DEBUG_LOG( @"Unspecified color used for layer %@", _number );

	return _color;
}

+ (UIColor*)colorForColorString:(NSString*)colorString
{
	// Convert to integer and swtich
	NSInteger color = [colorString intValue];

	switch( color )
	{
		case 1: // Busses: blue
			return RGB( 75, 75, 165 );
			
		case 2: // Nets, pads, vias
			return RGB( 75, 165, 75 );

		case 3:
			return RGBHEX( 0xb4b4b4 );

		case 4:	// Symbols
			return RGB( 165, 75, 75 );

		case 5:
			RGBHEX( 0x8d008f );

		case 6:
			RGBHEX( 0x8d9015 );

		case 7: // Values
			return RGB( 165, 165, 165 );

		case 8:
			return RGBHEX( 0x272727 );

		case 9:
			return RGBHEX( 0x0000b7 );

		case 10:
			return RGBHEX( 0x08ba00 );

		case 11:
			return RGBHEX( 0x00b6b4 );

		case 12:
			return RGBHEX( 0xb40000 );

		case 13:
			return RGBHEX( 0xb400b6 );

		case 14:
			return RGBHEX( 0xb5b800 );

		case 15:
			return RGBHEX( 0xb4b4b4 );

		default:
			DEBUG_LOG( @"Color not specified for layer %d", color );
			return RGBHEX( 0x000000 );	// Default color is black
	}
}

@end
