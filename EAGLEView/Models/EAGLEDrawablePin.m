//
//  EAGLEDrawablePin.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawablePin.h"
#import "DDXML.h"
#import "EAGLELayer.h"
#import "EAGLESchematic.h"
#import "EAGLEDrawableText.h"

static const CGFloat kPinNameTextSize = 1.8;
static const CGFloat kPinNamePadding = 2.54;	// Space between pin and name

@implementation EAGLEDrawablePin

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		NSString *rotationString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotationString];

		// Length
		NSString *lengthString = [[element attributeForName:@"length"] stringValue];
		if( [lengthString isEqualToString:@"short"] )
			_length = EAGLEDrawablePinLength_Short;
		else if( [lengthString isEqualToString:@"middle"] )
			_length = EAGLEDrawablePinLength_Medium;
		else if( [lengthString isEqualToString:@"point"] )
			_length = EAGLEDrawablePinLength_Point;
		else
			[NSException raise:@"Unknown length string" format:@"Unknown length: %@", lengthString];

		// Visible pin/pad text
		NSString *visible = [[element attributeForName:@"visible"] stringValue];
		_pinVisible = ( [visible isEqualToString:@"pin"] || [visible isEqualToString:@"both"] );
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Pin – length: %d, at %@", self.length, NSStringFromCGPoint( self.point )];
}

+ (CGFloat)lengthForPinLength:(EAGLEDrawablePinLength)pinLength
{
	switch( pinLength )
	{
		case EAGLEDrawablePinLength_Point:
			return 0;
			
		case EAGLEDrawablePinLength_Short:
			return 2.54;

		case EAGLEDrawablePinLength_Medium:
			return 2.54 * 2;

		case EAGLEDrawablePinLength_Long:
			return 2.54 * 3;
	}
}

- (void)drawInContext:(CGContextRef)context
{
	CGColorRef pinColor = [RGB( 165, 75, 75 ) CGColor];
	CGContextSetStrokeColorWithColor( context, pinColor );

	// Rotate
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );			// Translate so origin point is 0,0
	CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:self.rotation] );	// Now rotate. Otherwise, rotation center would be offset

	// Draw line
    CGContextBeginPath( context );
	CGContextSetLineWidth( context, 0.1524 );
    CGContextMoveToPoint( context, 0, 0);
    CGContextAddLineToPoint( context, [EAGLEDrawablePin lengthForPinLength:self.length], 0 );
    CGContextStrokePath( context );

	// Draw pin
	if( _pinVisible )
	{
		EAGLELayer *currentLayer = self.schematic.layers[ @96 ];	// Hardcoded layer for pin names
		NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:kPinNameTextSize * kFontSizeFactor],
									  NSForegroundColorAttributeName: currentLayer.color };

		CGSize textSize = [self.name sizeWithAttributes:attributes];
		CGContextTranslateCTM( context, [EAGLEDrawablePin lengthForPinLength:self.length] + kPinNamePadding, textSize.height/2 );
		CGContextScaleCTM( context, 1, -1 );

		if( _rotation == Rotation_R180 )
		{
			CGContextTranslateCTM( context, textSize.width, textSize.height );
			CGContextScaleCTM( context, -1, -1 );
		}

		[self.name drawAtPoint:CGPointZero withAttributes:attributes];
	}

	CGContextRestoreGState( context );
}

- (CGFloat)maxX
{
	return self.point.x + [EAGLEDrawablePin lengthForPinLength:self.length];
}

- (CGFloat)maxY
{
	return self.point.y + [EAGLEDrawablePin lengthForPinLength:self.length];
}


@end
