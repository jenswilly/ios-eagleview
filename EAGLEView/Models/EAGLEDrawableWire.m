//
//  EAGLEDrawableWire.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableWire.h"
#import "DDXML.h"
#import "EAGLESchematic.h"
#import "EAGLELayer.h"

@implementation EAGLEDrawableWire

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
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
	CGContextSetLineWidth( context, self.width );
	CGContextSetLineCap( context, kCGLineCapRound );
    CGContextMoveToPoint( context, self.point1.x, self.point1.y );
    CGContextAddLineToPoint( context, self.point2.x, self.point2.y );
    CGContextStrokePath( context );
}

@end
