//
//  EAGLECircle.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableCircle.h"
#import "DDXML.h"

@implementation EAGLEDrawableCircle

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_center = CGPointMake( x, y );

		CGFloat radius = [[[element attributeForName:@"radius"] stringValue] floatValue];
		_radius = radius;

		CGFloat width = [[[element attributeForName:@"width"] stringValue] floatValue];
		_width = width;
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Circle - center %@, radius: %.2f, width: %.2f", NSStringFromCGPoint( self.center ), self.radius, self.width];
}

- (void)drawInContext:(CGContextRef)context
{
	[super setStrokeColorFromLayerInContext:context];
	CGContextSetLineWidth( context, self.width );

	// Draw circle
	CGRect enclosingRect = CGRectMake( self.center.x - self.radius, self.center.y - self.radius, self.radius * 2, self.radius * 2 );
	CGContextStrokeEllipseInRect( context, enclosingRect );
}

- (CGFloat)maxX
{
	return self.center.x + self.radius;
}

- (CGFloat)maxY
{
	return self.center.y + self.radius;
}

- (CGFloat)minX
{
	return self.center.x - self.radius;
}

- (CGFloat)minY
{
	return self.center.y - self.radius;
}

- (CGPoint)origin
{
	return _center;
}

@end
