//
//  EAGLEDrawableRectangle.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableRectangle.h"
#import "DDXML.h"

@implementation EAGLEDrawableRectangle
{
	UIColor *_patternColor;
}

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
	return [NSString stringWithFormat:@"Rectangle: layer %@ from %@ to %@, width %.1f", self.layerNumber , NSStringFromCGPoint( self.point1 ), NSStringFromCGPoint( self.point2 ), self.width];
}

- (void)setFillPatternFromLayerInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGPatternCallbacks callbacks = { 0, [super patternFunctionForLayer], nil };

    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);

	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];
	_patternColor = currentLayer.color;
    CGPatternRef pattern = CGPatternCreate( (__bridge void *)(_patternColor), rect, CGAffineTransformIdentity, 24, 24, kCGPatternTilingConstantSpacing, YES, &callbacks );

    CGFloat alpha = 1.0;
    CGContextSetFillPattern( context, pattern, &alpha );
    CGPatternRelease( pattern );
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	[super setStrokeColorFromLayerInContext:context];
	[super setFillColorFromLayerInContext:context];

	CGRect rect = CGRectMake( self.point1.x, self.point1.y, self.point2.x - self.point1.x, self.point2.y - self.point1.y );

	/// Patterns
	if( [super patternFunctionForLayer] != nil )
		[self setFillPatternFromLayerInContext:context rect:rect];

	CGContextSetLineWidth( context, self.width );
	CGContextFillRect( context, rect );
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
