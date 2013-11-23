//
//  EAGLEDrawableText.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableText.h"
#import "DDXML.h"

@implementation EAGLEDrawableText

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_text = [element stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		CGFloat size = [[[element attributeForName:@"size"] stringValue] floatValue];
		_size = size;
	}

	return self;
}

- (void)drawInContext:(CGContextRef)context
{
//	[self setFillColorFromLayerInContext:context];
	CGContextSetFillColorWithColor( context, [[UIColor whiteColor] CGColor] );

	// Set font
	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:10] };
	[self.text drawAtPoint:self.point withAttributes:attributes];

	CGContextSetFillColorWithColor( context, [[UIColor whiteColor] CGColor] );
	NSString *tst = @"TEST";
	[tst drawAtPoint:CGPointMake(0, 0) withAttributes:attributes];

}

@end
