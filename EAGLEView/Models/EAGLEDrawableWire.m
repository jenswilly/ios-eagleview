//
//  EAGLEDrawableWire.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableWire.h"
#import "DDXML.h"
#import "EAGLEFile.h"
#import "EAGLELayer.h"

@implementation EAGLEDrawableWire

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
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Wire: layer %@ from %@ to %@, width %.1f", self.layerNumber , NSStringFromCGPoint( self.point1 ), NSStringFromCGPoint( self.point2 ), self.width];
}

- (void)drawInContext:(CGContextRef)context
{
	[self setStrokeColorFromLayerInContext:context];
    CGContextBeginPath( context );

	// "Hairline" width if width=0
	if( self.width == 0 )
	{
		CGAffineTransform transform = CGContextGetCTM( context );
		CGFloat scale = sqrt( transform.a * transform.a + transform.c * transform.c );
		CGContextSetLineWidth( context, 1.0f/scale );
	}
	else
	{
		CGContextSetLineWidth( context, self.width );
		CGContextSetLineCap( context, kCGLineCapRound );
	}
    CGContextMoveToPoint( context, self.point1.x, self.point1.y );
    CGContextAddLineToPoint( context, self.point2.x, self.point2.y );
    CGContextStrokePath( context );
}

- (CGFloat)maxX
{
	return MAX( self.point1.x, self.point2.x );
}

- (CGFloat)maxY
{
	return MAX( self.point1.y, self.point2.y );
}

- (CGFloat)minX
{
	return MIN( self.point1.x, self.point2.x );
}

- (CGFloat)minY
{
	return MIN( self.point1.y, self.point2.y );
}

- (CGPoint)origin
{
	return CGPointMake( self.point2.x - self.point1.x, self.point2.y - self.point1.y );
}

@end
