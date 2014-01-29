//
//  EAGLEDrawableSmd.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableSmd.h"
#import "DDXML.h"

@implementation EAGLEDrawableSmd

// <smd name="AVDD1" x="-6.05" y="6.9" dx="0.85" dy="3" layer="1" roundness="100" rot="R90"/>
- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		x = [[[element attributeForName:@"dx"] stringValue] floatValue];
		y = [[[element attributeForName:@"dy"] stringValue] floatValue];
		_size = CGSizeMake( x, y );

		_roundness = [[[element attributeForName:@"roundness"] stringValue] floatValue];

		NSString *rotationString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotationString];

	}

	return self;
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	// Translate coordinate system for text drawing
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );
	CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:self.rotation] );	// Now rotate. Otherwise, rotation center would be offset

	CGRect rect = CGRectMake( -_size.width / 2, -_size.height / 2, _size.width, _size.height );
	[super setFillColorFromLayerInContext:context];

	if( _roundness > 0 )
	{
		// Rounded corners. Use UIBezierPath instead of a simple rectangle.
		// Roundness is from 0 to 100. 0 means no round corners, 100 means rounded corners with a radius of half the smallest dimension (so the smallest side is a complete half-circle)
		UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:MIN( _size.width, _size.height ) / 2 * _roundness / 100];
		[roundedRectPath fill];
	}
	else
		CGContextFillRect( context, rect );

	CGContextRestoreGState( context );
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"SMD %@ - pos: %@, size: %@", _name, NSStringFromCGPoint( _point ), NSStringFromCGSize( _size )];
}

- (CGFloat)minX
{
	return _point.x - _size.width / 2;
}

- (CGFloat)maxX
{
	return _point.x + _size.width / 2;
}

- (CGFloat)minY
{
	return _point.y - _size.height / 2;
}

- (CGFloat)maxY
{
	return _point.y + _size.height / 2;
}

- (CGPoint)origin
{
	return _point;
}

- (CGRect)boundingRect
{
	return CGRectMake( _point.x - _size.width / 2, _point.y - _size.height / 2, _size.width, _size.height );
}

@end
