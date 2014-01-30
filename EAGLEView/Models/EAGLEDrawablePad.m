//
//  EAGLEDrawablePad.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawablePad.h"
#import "DDXML.h"

static const CGFloat kPadRestringFactor = 0.25;	// Specify as percentage value (i.e. 0.0 - 1.0)
static const CGFloat kPadRestringMin = 0.254;	// Specify min restring in mm
static const CGFloat kPadRestringMax = 0.508;	// Specify max restring in mm

@implementation EAGLEDrawablePad

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_drill = [[[element attributeForName:@"drill"] stringValue] floatValue];

		if( [element attributeForName:@"diameter"] )
			// Use specificed diamter
			_diameter = [[[element attributeForName:@"diameter"] stringValue] floatValue];
		else
		{
			// Calculate auto diameter if no diameter is specified. NOTE: we currenyly use fixed values for restring of 10mil, 25%, 20mil. These should properly be takes from the design rules instead.

			CGFloat autoWidth = kPadRestringFactor * _drill;
			if( autoWidth < kPadRestringMin )
				autoWidth = kPadRestringMin;
			else if( autoWidth > kPadRestringMax )
				autoWidth = kPadRestringMax;

			_diameter = _drill + autoWidth*2;	// * 2 since restring values are radius values and this is a diameter
		}

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		NSString *rotationString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotationString];

		_layerNumber = @17;	// Pads are always layer 17
	}

	return self;
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	// Translate coordinate system for text drawing
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );

	CGFloat width = (_diameter - _drill) / 2;
	CGContextSetLineWidth( context, width );

	[super setStrokeColorFromLayerInContext:context];

    CGContextAddArc( context, 0, 0, _diameter/2 - width/2, 0, M_PI * 2, YES );
    CGContextStrokePath( context );

	CGContextRestoreGState( context );
}

- (CGFloat)minX
{
	return _point.x - MAX( _drill, _diameter );
}

- (CGFloat)maxX
{
	return _point.x + MAX( _drill, _diameter );
}

- (CGFloat)minY
{
	return _point.y - MAX( _drill, _diameter );
}

- (CGFloat)maxY
{
	return _point.y + MAX( _drill, _diameter );
}

- (CGPoint)origin
{
	return _point;
}

- (CGRect)boundingRect
{
	return CGRectMake( [self minX], [self minY], MAX( _drill, _diameter ), MAX( _drill, _diameter ));
}


@end
