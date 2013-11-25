//
//  EAGLEInstance.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEInstance.h"
#import "DDXML.h"
#import "EAGLESchematic.h"
#import "EAGLEPart.h"
#import "EAGLELibrary.h"
#import "EAGLEDeviceset.h"
#import "EAGLEGate.h"
#import "EAGLESymbol.h"

@implementation EAGLEInstance

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_part_name = [[element attributeForName:@"part"] stringValue];
		_gate_name = [[element attributeForName:@"gate"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		_smashed = [[[element attributeForName:@"smashed"] stringValue] boolValue];

		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		if( rotString == nil )
			_rotation = 0;
		else if( [rotString isEqualToString:@"R90"] )
			_rotation = M_PI_2;
		else if( [rotString isEqualToString:@"R270"] )
			_rotation = M_PI_2 * 3;
		else if( [rotString isEqualToString:@"R180"] )
			_rotation = M_PI;
		else
			[NSException raise:@"Unknown rotation string" format:@"Unknown rotation: %@", rotString];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Instance – part %@, gate %@", self.part_name, self.gate_name];
}

- (EAGLESymbol *)symbol
{
	// Get part
	EAGLEPart *part = [self.schematic partWithName:self.part_name];

	// Library
	EAGLELibrary *library = [self.schematic libraryWithName:part.library_name];

	// Deviceset
	EAGLEDeviceset *deviceset = [library devicesetWithName:part.deviceset_name];

	// Gate
	EAGLEGate *gate = [deviceset gateWithName:self.gate_name];

	// Symbol
	EAGLESymbol *symbol = [library symbolWithName:gate.symbol_name];
	return symbol;
}

- (void)drawInContext:(CGContextRef)context
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0
	CGContextRotateCTM( context, self.rotation );					// Now rotate. Otherwise, rotation center would be offset

	[[self symbol] drawAtPoint:CGPointZero context:context];		// Draw at point 0,0 since coordinate system has been moved to point

	CGContextRestoreGState( context );
}

@end
