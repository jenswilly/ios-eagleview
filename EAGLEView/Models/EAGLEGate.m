//
//  EAGLEGate.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEGate.h"
#import "DDXML.h"

@implementation EAGLEGate

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_symbol_name = [[element attributeForName:@"symbol"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Gate %@ – symbol: %@", self.name, self.symbol_name ];
}

@end
