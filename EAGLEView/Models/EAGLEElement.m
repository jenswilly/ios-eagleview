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
#import "DDXML.h"

@implementation EAGLEElement
{
	NSDictionary *_smashedAttributes;
}

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
		NSString *libraryName = [[element attributeForName:@"library"] stringValue];
		NSString *packageName = [[element attributeForName:@"package"] stringValue];
		_package = [self.board packageNamed:packageName inLibraryNamed:libraryName];
		
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
										   @">VALUE": _value,
										   @">Value": _value,
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

- (void)drawInContext:(CGContextRef)context
{
	// Rotate if necessary. First offset coordinate system to origin point then rotate. State is pushed/popped.
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );	// Translate so origin point is 0,0

	if( self.rotation == Rotation_Mirror_MR0 )
		// Mirror, not rotate
		CGContextScaleCTM( context, -1, 1 );
	else
		CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:self.rotation] );	// Now rotate. Otherwise, rotation center would be offset

	[self.package drawInContext:context smashed:self.smashed mirrored:( self.rotation == Rotation_Mirror_MR0 )];

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
	CGFloat maxX = [self.package maxX];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			maxX = MAX( maxX, [attribute maxX] );

	return maxX + self.point.x;
}

- (CGFloat)maxY
{
	CGFloat maxY = [self.package maxY];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			maxY = MAX( maxY, [attribute maxY] );

	return maxY + self.point.y;
}

- (CGFloat)minX
{
	CGFloat minX = [self.package minX];

	if( _smashedAttributes )
		for( EAGLEAttribute *attribute in [_smashedAttributes allValues] )
			minX = MIN( minX, [attribute minX] );

	return minX + self.point.x;
}

- (CGFloat)minY
{
	CGFloat minY = [self.package minY];

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
