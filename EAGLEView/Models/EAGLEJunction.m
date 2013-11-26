//
//  EAGLEJunction.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEJunction.h"
#import "DDXML.h"

static CGFloat kJunctionDiameter = 0.8f;	// Diameter of junction circle

@implementation EAGLEJunction

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	// Add layer attribute so we'll get the correct color since junction elements have no layer attribute
	DDXMLNode *layerAttribute = [DDXMLNode attributeWithName:@"layer" stringValue:@"91"];
	[element addAttribute:layerAttribute];

	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Junction – at %@", NSStringFromCGPoint( self.point )];
}

- (void)drawInContext:(CGContextRef)context
{
	[super setStrokeColorFromLayerInContext:context];
	[super setFillColorFromLayerInContext:context];

	// Draw filled circle
	CGRect enclosingRect = CGRectMake( self.point.x - kJunctionDiameter/2, self.point.y - kJunctionDiameter/2, kJunctionDiameter, kJunctionDiameter );
	CGContextFillEllipseInRect( context, enclosingRect);
}

@end
