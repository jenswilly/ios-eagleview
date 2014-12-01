//
//  EAGLEElement.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEElement.h"
#import "EAGLEAttribute.h"
#import "EAGLEPackage.h"
#import "EAGLEBoard.h"
#import "EAGLEDrawableText.h"
#import "DDXML.h"

@implementation EAGLEElement

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_value = [[element attributeForName:@"value"] stringValue];

		_smashed = [[[element attributeForName:@"smashed"] stringValue] boolValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		// Package
		_library_name = [[element attributeForName:@"library"] stringValue];
		NSString *packageName = [[element attributeForName:@"package"] stringValue];
		_package = [self.board packageNamed:packageName inLibraryNamed:_library_name];
		
		// Smashed?
		_smashed = [[[element attributeForName:@"smashed"] stringValue] boolValue];
		if( _smashed )
		{
			// The instance is smashed so extract individual attributes and remember positions

			NSError *error = nil;
			NSArray *attributes = [element nodesForXPath:@"attribute[ not( @display = \"off\") ]" error:&error];
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
					attribute.text = _value;
					tmpSmashedAttributes[ @">VALUE" ] = attribute;
				}
				else if( [attribute.name isEqualToString:@"NAME"] )
				{
					// VALUE attribute
					attribute.text = _name;
					tmpSmashedAttributes[ @">NAME" ] = attribute;
				}
				else
					NSLog( @"Ignoring unknown smashed attribute: %@.", attribute.name );
			}
			_smashedAttributes = [NSDictionary dictionaryWithDictionary:tmpSmashedAttributes];
		}

		// Set texts for placeholders on the package
		_package.textsForPlaceholders = @{ @">NAME": _name,
										   @">Name": _name,
										   @">name": _name,
										   @">VALUE": _value,
										   @">Value": _value,
										   @">value": _value,
										   @">DRAWING_NAME": (self.file.fileName ? self.file.fileName : @""),
										   @">LAST_DATE_TIME": [self.file dateString] };

		// Set list of smashed attributes which should _not_ be drawn by the symbol
		_package.placeholdersToSkip = [_smashedAttributes allKeys];

		// Rotation
		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotString];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Element %@ - value: %@", _name, _value];
}

- (void)drawInContext:(CGContextRef)context layerNumber:(NSNumber*)layerNumber
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0
	[EAGLEDrawableObject transformContext:context forRotation:self.rotation];

	[self.package drawInContext:context smashed:self.smashed mirrored:[EAGLEDrawableObject rotationIsMirrored:self.rotation] layerNumber:layerNumber];

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

	[self.package drawInContext:context smashed:self.smashed mirrored:[EAGLEDrawableObject rotationIsMirrored:self.rotation]];

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
	CGFloat maxX = -MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.package.components )
		// Skip text elements for smashed elements
		if( !(self.smashed && [drawable isKindOfClass:[EAGLEDrawableText class]]) )
			maxX = MAX( maxX, [drawable maxX] );

	return maxX + self.point.x;
}

- (CGFloat)maxY
{
	CGFloat maxY = -MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.package.components )
		// Skip text elements for smashed elements
		if( !(self.smashed && [drawable isKindOfClass:[EAGLEDrawableText class]]) )
			maxY = MAX( maxY, [drawable maxY] );

	return maxY + self.point.y;
}

- (CGFloat)minX
{
	CGFloat minX = MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.package.components )
		// Skip text elements for smashed elements
		if( !(self.smashed && [drawable isKindOfClass:[EAGLEDrawableText class]]) )
			minX = MIN( minX, [drawable minX] );
	
	return minX + self.point.x;
}

- (CGFloat)minY
{
	CGFloat minY = MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.package.components )
		// Skip text elements for smashed elements
		if( !(self.smashed && [drawable isKindOfClass:[EAGLEDrawableText class]]) )
			minY = MIN( minY, [drawable minY] );

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

	if( [EAGLEDrawableObject rotationIsMirrored:self.rotation] )
	{
		// Mirrored: swap X coordinates
//		CGFloat tmp = point1.x;
//		point1.x = point2.x;
//		point2.x = tmp;

		point1.x *= -1;
		point2.x *= -1;

	}
//	else
	{
		// Rotatation: rotate points
		CGFloat alpha = [EAGLEDrawableObject radiansForRotation:self.rotation];
		CGPoint point1R = CGPointMake( point1.x * cosf( alpha ) - point1.y * sinf( alpha ), point1.x * sinf( alpha ) + point1.y * cosf( alpha ));
		CGPoint point2R = CGPointMake( point2.x * cosf( alpha ) - point2.y * sinf( alpha ), point2.x * sinf( alpha ) + point2.y * cosf( alpha ));

		if( [EAGLEDrawableObject rotationIsMirrored:self.rotation] )
		{
			point1R.x *= -1;
			point1R.y *= -1;

			point2R.x *= -1;
			point2R.y *= -1;
		}

		CGFloat minX = MIN( point1R.x, point2R.x );
		CGFloat maxX = MAX( point1R.x, point2R.x );
		CGFloat minY = MIN( point1R.y, point2R.y );
		CGFloat maxY = MAX( point1R.y, point2R.y );

		boundingRect = CGRectMake( minX + self.point.x, minY + self.point.y, maxX-minX, maxY-minY );
	}

	return boundingRect;
}

- (BOOL)isEqual:(id)object
{
	if( ![object isKindOfClass:[self class]] )
		return NO;	// Wrong class

	return [((EAGLEElement*)object).name isEqualToString:self.name];
}

@end
