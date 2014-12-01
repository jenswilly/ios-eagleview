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
	EAGLESymbol *_symbol;
	EAGLEPart *_part;
	EAGLEDeviceset *_deviceset;
	EAGLELibrary *_library;
	EAGLEGate *_gate;
	NSString *_valueText;
	NSDictionary *_textsForPlaceholders;	// Placeholder values for this instance
}

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
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
				EAGLEAttribute *attribute = [[EAGLEAttribute alloc] initFromXMLElement:childElement inFile:file];
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

		// Get texts for placeholders. These will be set on the symbol when drawing.
		_textsForPlaceholders = @{ @">NAME": [self part].name,
										  @">Name": [self part].name,
										  @">name": [self part].name,
										  @">VALUE": [self valueText],
										  @">Value": [self valueText],
										  @">value": [self valueText],
										  @">DRAWING_NAME": (self.file.fileName ? self.file.fileName : @""),
										  @">LAST_DATE_TIME": [self.file dateString] };

		// Rotation
		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotString];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Instance - part %@, gate %@", self.part_name, self.gate_name];
}

/**
 * Returns the string to use as value.
 *
 * Check if value is empty. If so _and_ part' prefix matches the deviceset's prefix, use the deviceset's name. If not empty, use the value.
 */
- (NSString*)valueText
{
	if( _valueText == nil )
	{
		// For the value string, check if value is empty. If so _and_ part' prefix matches the deviceset's prefix, use the deviceset's name. If not empty, use the value
		if( [[self part].value length] == 0  )
		{
			_valueText = [self deviceset].name;
		}
		else
			_valueText = [self part].value;
	}

	return _valueText;
}

- (EAGLEPart*)part
{
	if( _part == nil )
		_part = [self.schematic partWithName:self.part_name];

	return _part;
}

- (EAGLELibrary*)library
{
	if( _library == nil )
		_library = [self.file libraryWithName:[self part].library_name];

	return _library;
}

- (EAGLEDeviceset*)deviceset
{
	if( _deviceset == nil )
		_deviceset = [[self library] devicesetWithName:[self part].deviceset_name];

	return _deviceset;
}

- (EAGLEGate*)gate
{
	if( _gate == nil )
		_gate = [[self deviceset] gateWithName:self.gate_name];

	return _gate;
}

- (EAGLESymbol *)symbol
{
	// Symbol
	if( _symbol == nil )
	{
		_symbol = [[self library] symbolWithName:[self gate].symbol_name];

		/*
		_symbol.textsForPlaceholders = @{ @">NAME": [self part].name,
										 @">Name": [self part].name,
										  @">name": [self part].name,
										 @">VALUE": [self valueText],
										 @">Value": [self valueText],
										  @">value": [self valueText],
										 @">DRAWING_NAME": (self.file.fileName ? self.file.fileName : @""),
										 @">LAST_DATE_TIME": [self.file dateString] };
		 */

		// Set list of smashed attributes which should _not_ be drawn by the symbol
		_symbol.placeholdersToSkip = [_smashedAttributes allKeys];
	}
	
	return _symbol;
}

- (void)drawInContext:(CGContextRef)context layerNumber:(NSNumber*)layerNumber
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0
	[EAGLEDrawableObject transformContext:context forRotation:self.rotation];

	// Set symbol's placeholder texts before drawing. The same symbol might be drawn for several instances so we need to set placeholder texts now.
	[self symbol].textsForPlaceholders = _textsForPlaceholders;
	[[self symbol] drawAtPoint:CGPointZero context:context flipTexts:(self.rotation == Rotation_R180 || self.rotation == Rotation_R270 ) isMirrored:[EAGLEDrawableObject rotationIsMirrored:self.rotation] smashed:self.smashed layerNumber:layerNumber];		// Draw at point 0,0 since coordinate system has been moved to point

	CGContextRestoreGState( context );

	// Do we need to draw any smashed attributes?
	if( _smashedAttributes )
	{
		// Yes: let's do it. NOTE: coordinates are absolute and the coordinate system has been restored so we're good to go.
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			if( [attribute.layerNumber isEqual:layerNumber] )
				[attribute drawInContext:context];
	}
}

- (void)drawInContext:(CGContextRef)context
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0
	[EAGLEDrawableObject transformContext:context forRotation:self.rotation];

	[[self symbol] drawAtPoint:CGPointZero context:context flipTexts:(self.rotation == Rotation_R180 || self.rotation == Rotation_R270 ) isMirrored:[EAGLEDrawableObject rotationIsMirrored:self.rotation] smashed:self.smashed];		// Draw at point 0,0 since coordinate system has been moved to point

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

- (CGPoint)origin
{
	return self.point;
}

- (CGRect)boundingRect
{
	CGRect boundingRect = CGRectMake( [self minX], [self minY], [self maxX]-[self minX], [self maxY]-[self minY] );
	CGPoint point1 = CGPointMake( [self minX] - self.point.x, [self minY] - self.point.y );
	CGPoint point2 = CGPointMake( [self maxX] - self.point.x, [self maxY] - self.point.y );

	if( self.rotation == Rotation_Mirror_MR0 )
	{
		// Mirrored: swap X coordinates
		CGFloat tmp = point1.x;
		point1.x = point2.x;
		point2.x = tmp;
	}
	else
	{
		// Rotatation: rotate points
		CGFloat alpha = [EAGLEDrawableObject radiansForRotation:self.rotation];
		CGPoint point1R = CGPointMake( point1.x * cosf( alpha ) - point1.y * sinf( alpha ), point1.x * sinf( alpha ) + point1.y * cosf( alpha ));
		CGPoint point2R = CGPointMake( point2.x * cosf( alpha ) - point2.y * sinf( alpha ), point2.x * sinf( alpha ) + point2.y * cosf( alpha ));

		CGFloat minX = MIN( point1R.x, point2R.x );
		CGFloat maxX = MAX( point1R.x, point2R.x );
		CGFloat minY = MIN( point1R.y, point2R.y );
		CGFloat maxY = MAX( point1R.y, point2R.y );
		boundingRect = CGRectMake( minX + self.point.x, minY + self.point.y, maxX-minX, maxY-minY );
	}

	return boundingRect;
}

@end
