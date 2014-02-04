//
//  EAGLEDrawableArc.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableArc.h"
#import "DDXML.h"

@implementation EAGLEDrawableArc
{
	CGFloat _radius;
	CGPoint _center;
	CGFloat _startAngle;
	CGFloat _endAngle;
}

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		CGFloat x = [[[element attributeForName:@"x1"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y1"] stringValue] floatValue];
		_point1 = CGPointMake( x, y );

		x = [[[element attributeForName:@"x2"] stringValue] floatValue];
		y = [[[element attributeForName:@"y2"] stringValue] floatValue];
		_point2 = CGPointMake( x, y );

		_width = [[[element attributeForName:@"width"] stringValue] floatValue];
		_curve = [[[element attributeForName:@"curve"] stringValue] floatValue];

		// Calculate 
		[self calculateArcParameters];
	}

	return self;
}

- (void)calculateArcParameters
{
	CGFloat alpha;
	CGFloat a;

	/*
	 * a		Distance between start and end points
	 * alpha	Angle i radians
	 * _radius	Radius
	 * A
	 * Px
	 */

	// 1. Calculate alpha, a and radius
	a = sqrtf( powf( (_point2.x-_point1.x),2 ) + powf( (_point2.y-_point1.y), 2 ));
	alpha = M_PI * _curve/180;
	_radius = fabsf( (a/2) / sinf( alpha/2 ));

	// 2. Offset points, so P1 is at (0,0)
	CGPoint P2 = CGPointMake( _point2.x - _point1.x, _point2.y - _point1.y );

	// 3. Find angle A from P1 to P2
	CGFloat A = atan2f( P2.y, P2.x );

	// 4. Rotate P2 by -A so P2 will lie on the X-axis
	// Clockwise or counter-clockwise?
	CGPoint Px;
	/*
	if( -A >= 0 )
	{
		// Counter-clockwise
		CGFloat x = P2.x * cosf( -A ) - P2.y * sinf( -A );
		CGFloat y = P2.x * sinf( -A ) + P2.y * cosf( -A );
		Px = CGPointMake( x, y );
	}
	else
	{
		// Clockwise
		CGFloat x = P2.x * cosf( -A ) + P2.y * sinf( -A );
		CGFloat y = -P2.x * sinf( -A ) + P2.y * cosf( -A );
		Px = CGPointMake( x, y );
	}
	*/
	Px = CGPointMake( a, 0 );

	// 5. Find center point
	CGPoint center;
	center.x = a/2;
	center.y = cosf( asinf( a / (2 * _radius ))) * _radius;

	// Rotate the center point back into position. We might also need to move the center Y coord below the X axis. This – and the rotation direction – depends on the curve direction and whether P2.y is > or < 0.
	BOOL rotateClockwise = NO;

	if( P2.y < 0 && _curve < 0 )
	{
		center.y *= -1;
		rotateClockwise = (A < 0);
	}
	else if( P2.y >= 0 && _curve < 0 )
	{
		center.y *= -1;
		rotateClockwise = (A > 0);
	}
	else if( P2.y < 0 && _curve >= 0 )
	{
		rotateClockwise = (A > 0);
	}
	else if( P2.y >= 0 && _curve >= 0 )
	{
		rotateClockwise = (A > 0);
	}

	// 6. Rotate center point by A
	CGPoint center2;
	if( !rotateClockwise )
	{
		// Clockwise
		CGFloat x = center.x * cosf( A ) + center.y * sinf( A );
		CGFloat y = -center.x * sinf( A ) + center.y * cosf( A );
		center2 = CGPointMake( x, y );
	}
	else
	{
		// Counter-clockwise
		CGFloat x = center.x * cosf( A ) - center.y * sinf( A );
		CGFloat y = center.x * sinf( A ) + center.y * cosf( A );
		center2 = CGPointMake( x, y );
	}

	// 7. Offset back
	_center.x = center2.x + _point1.x;
	_center.y = center2.y + _point1.y;

	// 8. startAngle
	_startAngle = atan2f( _point1.y - _center.y, _point1.x - _center.x );
	_endAngle = atan2f( _point2.y - _center.y, _point2.x - _center.x );
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Arc: layer %@ from %@ to %@, width %.1f, curve: %.f", self.layerNumber , NSStringFromCGPoint( self.point1 ), NSStringFromCGPoint( self.point2 ), self.width, self.curve];
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	[super setStrokeColorFromLayerInContext:context];
	CGContextSetLineWidth( context, self.width );

	CGContextBeginPath( context );
	CGContextAddArc( context, _center.x, _center.y, _radius, _startAngle, _endAngle, (self.curve < 0 ? 1 : 0) );
	CGContextDrawPath( context, kCGPathStroke );
}

- (CGFloat)maxX
{
	return MAX( _point1.x, _point2.x );
}

- (CGFloat)maxY
{
	return MAX( _point1.y, _point2.y );
}

- (CGFloat)minX
{
	return MIN( _point1.x, _point2.x );
}

- (CGFloat)minY
{
	return MIN( _point1.y, _point2.y );
}

- (CGPoint)origin
{
	return _center;
}

@end
