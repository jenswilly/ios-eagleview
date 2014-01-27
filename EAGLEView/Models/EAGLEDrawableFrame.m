//
//  EAGLEDrawableFrame.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 20/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableFrame.h"
#import "DDXML.h"

static CGFloat frameLineWidth = 0.508;

@implementation EAGLEDrawableFrame

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

		_width = frameLineWidth;
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Frame: layer %@ from %@ to %@, width %.1f", self.layerNumber , NSStringFromCGPoint( self.point1 ), NSStringFromCGPoint( self.point2 ), self.width];
}

- (void)drawInContext:(CGContextRef)context
{
	[super setStrokeColorFromLayerInContext:context];
	[super setFillColorFromLayerInContext:context];
	CGContextSetLineWidth( context, self.width );
	CGContextStrokeRect( context, CGRectMake( self.point1.x, self.point1.y, self.point2.x - self.point1.x, self.point2.y - self.point1.y ) );
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
	return self.point1;
}

@end
