//
//  EAGLEDrawableVia.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableVia.h"
#import "DDXML.h"

@implementation EAGLEDrawableVia

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_layerNumber = @18;	// Layer is hardcoded

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		_drill = [[[element attributeForName:@"drill"] stringValue] floatValue];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Via – at %@, drill: %.2f", NSStringFromCGPoint( _point), _drill];
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	// Translate coordinate system for text drawing
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );

	[super setFillColorFromLayerInContext:context];

    CGContextAddArc( context, 0, 0, _drill/2, 0, M_PI * 2, YES );
    CGContextFillPath( context );

	CGContextRestoreGState( context );
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
