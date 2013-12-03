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
#import "EAGLEAttribute.h"

@implementation EAGLEInstance
{
	NSDictionary *_smashedAttributes;
}

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_part_name = [[element attributeForName:@"part"] stringValue];
		_gate_name = [[element attributeForName:@"gate"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		// Smashed?
		_smashed = [[[element attributeForName:@"smashed"] stringValue] boolValue];
		if( _smashed )
		{
			// The instance is smashed so extract individual attributes and remember positions

			NSError *error = nil;
			NSArray *attributes = [element nodesForXPath:@"attribute" error:&error];
			EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

			NSMutableDictionary *tmpSmashedAttributes = [[NSMutableDictionary alloc] init];
			for( DDXMLElement *childElement in attributes )
			{
				EAGLEAttribute *attribute = [[EAGLEAttribute alloc] initFromXMLElement:childElement inSchematic:schematic];
				if( !attribute )
				{
					NSLog( @"Could not create EAGLEAttribute from element: %@", [childElement XMLString] );
					continue;
				}

				if( [attribute.name isEqualToString:@"VALUE"] )
				{
					// VALUE attribute
					attribute.text = [self valueText];
					tmpSmashedAttributes[ @">VALUE" ] = attribute;
				}
				else if( [attribute.name isEqualToString:@"NAME"] )
				{
					// VALUE attribute
					attribute.text = self.part_name;
					tmpSmashedAttributes[ @">NAME" ] = attribute;
				}
				else
					NSLog( @"Ignoring unknown smashed attribute: %@.", attribute.name );
			}
			_smashedAttributes = [NSDictionary dictionaryWithDictionary:tmpSmashedAttributes];
		}

		// Rotation
		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotString];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Instance – part %@, gate %@", self.part_name, self.gate_name];
}

/**
 * Returns the string to use as value.
 *
 * Check if value is empty. If so _and_ part' prefix matches the deviceset's prefix, use the deviceset's name. If not empty, use the value.
 */
- (NSString*)valueText
{
	// Get part
	EAGLEPart *part = [self.schematic partWithName:self.part_name];

	// Library
	EAGLELibrary *library = [self.schematic libraryWithName:part.library_name];

	// Deviceset
	EAGLEDeviceset *deviceset = [library devicesetWithName:part.deviceset_name];

	// For the value string, check if value is empty. If so _and_ part' prefix matches the deviceset's prefix, use the deviceset's name. If not empty, use the value
	NSString *valueText;
	if( [part.value length] == 0  )
	{
		valueText = deviceset.name;
	}
	else
		valueText = part.value;
	
	return valueText;
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
	symbol.textsForPlaceholders = @{ @">NAME": part.name,
									 @">VALUE": [self valueText] };

	// Set list of smashed attributes which should _not_ be drawn by the symbol
	symbol.placeholdersToSkip = [_smashedAttributes allKeys];
	
	return symbol;
}

- (void)drawInContext:(CGContextRef)context
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0
	CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:self.rotation] );					// Now rotate. Otherwise, rotation center would be offset

	[[self symbol] drawAtPoint:CGPointZero context:context flipTexts:(self.rotation == Rotation_R180 || self.rotation == Rotation_R270)];		// Draw at point 0,0 since coordinate system has been moved to point

	CGContextRestoreGState( context );

	// Do we need to draw any smashed attributes?
	if( _smashedAttributes )
	{
		// Yes: let's do it. NOTE: coordinates are absolute and the coordinate system has been restored so we're good to go.
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			[attribute drawInContext:context];
	}
}

- (CGFloat)maxX
{
	CGFloat maxX = [[self symbol] maxX];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			maxX = MAX( maxX, [attribute maxX] );

	return maxX + self.point.x;
}

- (CGFloat)maxY
{
	CGFloat maxY = [[self symbol] maxY];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			maxY = MAX( maxY, [attribute maxY] );

	return maxY + self.point.y;
}

- (CGFloat)minX
{
	CGFloat minX = [[self symbol] minX];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			minX = MIN( minX, [attribute minX] );

	return minX + self.point.x;
}

- (CGFloat)minY
{
	CGFloat minY = [[self symbol] minY];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			minY = MAX( minY, [attribute minY] );

	return minY + self.point.y;
}

@end
