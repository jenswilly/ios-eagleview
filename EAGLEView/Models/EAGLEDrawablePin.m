//
//  EAGLEDrawablePin.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawablePin.h"
#import "DDXML.h"

@implementation EAGLEDrawablePin

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		if( rotString == nil )
			_rotation = 0;
		else if( [rotString isEqualToString:@"R90"] )
			_rotation = M_PI_2;
		else if( [rotString isEqualToString:@"R270"] )
			_rotation = M_PI_2 * 3;
		else if( [rotString isEqualToString:@"R180"] )
			_rotation = M_PI;
		else
			[NSException raise:@"Unknown rotation string" format:@"Unknown rotation: %@", rotString];


		NSString *lengthString = [[element attributeForName:@"length"] stringValue];
		if( [lengthString isEqualToString:@"short"] )
			_length = EAGLEDrawablePinLength_Short;
		else
			[NSException raise:@"Unknown length string" format:@"Unknown length: %@", lengthString];
	}

	return self;
}

+ (CGFloat)lengthForPinLength:(EAGLEDrawablePinLength)pinLength
{
	switch( pinLength )
	{
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
	CGContextRotateCTM( context, self.rotation );

	// Draw line
    CGContextBeginPath( context );
	CGContextSetLineWidth( context, 0.1524 );
    CGContextMoveToPoint( context, self.point.x, self.point.y );
    CGContextAddLineToPoint( context, [EAGLEDrawablePin lengthForPinLength:self.length], 0 );
    CGContextStrokePath( context );

	CGContextRestoreGState( context );
}
@end
