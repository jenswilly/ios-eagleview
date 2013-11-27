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
	CGFloat radius;
	CGPoint center;
	CGFloat startAngle;
	CGFloat endAngle;
}
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
	return [NSString stringWithFormat:@"Arc: layer %@ from %@ to %@, width %.1f, curve: %.f", self.layerNumber , NSStringFromCGPoint( self.point1 ), NSStringFromCGPoint( self.point2 ), self.width, self.curve];
}

@end
