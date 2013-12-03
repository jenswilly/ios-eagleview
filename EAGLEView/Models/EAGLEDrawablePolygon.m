//
//  EAGLEDrawablePolygon.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawablePolygon.h"
#import "DDXML.h"

@implementation EAGLEDrawablePolygon

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		// Width
		CGFloat width = [[[element attributeForName:@"width"] stringValue] floatValue];
		_width = width;

		// Vertices
		NSError *error = nil;
		NSArray *vertices = [element nodesForXPath:@"vertex" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpVertices = [[NSMutableArray alloc] initWithCapacity:[vertices count]];
		for( DDXMLElement *childElement in vertices )
		{
			CGFloat x = [[[childElement attributeForName:@"x"] stringValue] floatValue];
			CGFloat y = [[[childElement attributeForName:@"y"] stringValue] floatValue];
			[tmpVertices addObject:[NSValue valueWithCGPoint:CGPointMake( x, y )]];
		}
		_vertices = [NSArray arrayWithArray:tmpVertices];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Polygon – width: %.2f, %d vertices", self.width, (int)[self.vertices count]];
}

- (void)drawInContext:(CGContextRef)context
{
	// If no points, return immediately
	if( [self.vertices count] == 0 )
		return;

	[self setStrokeColorFromLayerInContext:context];
	[self setFillColorFromLayerInContext:context];
	CGContextSetLineWidth( context, self.width );

	// Move to first point
	CGPoint firstPoint = [self.vertices[ 0 ] CGPointValue];
    CGContextMoveToPoint( context, firstPoint.x, firstPoint.y );

	// Iterate rest of the points
	for( int i = 1; i < [self.vertices count]; i++ )
	{
		CGPoint nextPoint = [self.vertices[ i ] CGPointValue];
		CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y );
	}

	// Fill polygon
    CGContextFillPath(context);
}

- (CGFloat)maxX
{
	CGFloat maxX = -MAXFLOAT;
	for( NSValue *vertex in self.vertices )
	{
		CGPoint point = [vertex CGPointValue];
		maxX = MAX( maxX, point.x );
	}

	return maxX;
}

- (CGFloat)maxY
{
	CGFloat maxY = -MAXFLOAT;
	for( NSValue *vertex in self.vertices )
	{
		CGPoint point = [vertex CGPointValue];
		maxY = MAX( maxY, point.y );
	}

	return maxY;
}

- (CGFloat)minX
{
	CGFloat minX = MAXFLOAT;
	for( NSValue *vertex in self.vertices )
	{
		CGPoint point = [vertex CGPointValue];
		minX = MIN( minX, point.x );
	}

	return minX;
}

- (CGFloat)minY
{
	CGFloat minY = MAXFLOAT;
	for( NSValue *vertex in self.vertices )
	{
		CGPoint point = [vertex CGPointValue];
		minY = MIN( minY, point.y );
	}

	return minY;
}

@end
