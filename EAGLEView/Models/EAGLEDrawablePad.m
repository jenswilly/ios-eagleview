//
//  EAGLEDrawablePad.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawablePad.h"
#import "DDXML.h"

@implementation EAGLEDrawablePad

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_drill = [[[element attributeForName:@"drill"] stringValue] floatValue];
		_diameter = [[[element attributeForName:@"diameter"] stringValue] floatValue];

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

	// Flip and translate coordinate system for text drawing
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
