//
//  EAGLEDrawableHole.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 04/02/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableHole.h"
#import "DDXML.h"

@implementation EAGLEDrawableHole

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_layerNumber = @45;	// Layer is hardcoded

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		_drill = [[[element attributeForName:@"drill"] stringValue] floatValue];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Hole – at %@, drill %.2f", NSStringFromCGPoint( self.point ), self.drill];
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	[super setStrokeColorFromLayerInContext:context];
	
	// Holes have hairline path (i.e. 1 px regardless of zoom level) like dimensions
	CGAffineTransform transform = CGContextGetCTM( context );
	CGFloat scale = sqrt( transform.a * transform.a + transform.c * transform.c );
	CGContextSetLineWidth( context, 1.0f/scale );

	CGContextAddArc( context, _point.x, _point.y, _drill/2, 0, 2*M_PI, 0 );
	CGContextStrokePath( context );
}

- (CGFloat)minX
{
	return _point.x - _drill;
}

- (CGFloat)maxX
{
	return _point.x + _drill;
}

- (CGFloat)minY
{
	return _point.y - _drill;
}

- (CGFloat)maxY
{
	return _point.y + _drill;
}

- (CGPoint)origin
{
	return _point;
}

- (CGRect)boundingRect
{
	return CGRectMake( [self minX], [self minY], _drill, _drill );
}

@end
