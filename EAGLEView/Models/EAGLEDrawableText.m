//
//  EAGLEDrawableText.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableText.h"
#import "DDXML.h"
#import "EAGLESchematic.h"
#import "EAGLELayer.h"

const CGFloat kFontSizeFactor = 1.30;	// Font size is multiplied by this factor to get the point size

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
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Text '%@' – at %@", self.text, NSStringFromCGPoint( self.point )];
}

- (void)drawInContext:(CGContextRef)context
{
	// Flip and translate coordinate system for text drawing
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );
	CGContextRotateCTM( context, self.rotation );

	// Set color
	EAGLELayer *currentLayer = self.schematic.layers[ self.layerNumber ];

	// Set font properties
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor],
								  NSForegroundColorAttributeName: currentLayer.color,
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	NSString *stringToDraw = (self.valueText ? self.valueText : self.text);
	CGSize textSize = [stringToDraw sizeWithAttributes:attributes];
	CGContextTranslateCTM( context, 0, textSize.height );
	CGContextScaleCTM( context, 1, -1 );

	// Draw string
	[stringToDraw drawAtPoint:CGPointZero withAttributes:attributes];

	CGContextRestoreGState( context );
}

- (CGFloat)maxX
{
	// Calculate size with same properties as when drawing
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor],
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	NSString *stringToDraw = (self.valueText ? self.valueText : self.text);
	CGSize textSize = [stringToDraw sizeWithAttributes:attributes];

	return self.point.x + textSize.width;
}

- (CGFloat)maxY
{
	// Calculate size with same properties as when drawing
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor],
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	NSString *stringToDraw = (self.valueText ? self.valueText : self.text);
	CGSize textSize = [stringToDraw sizeWithAttributes:attributes];

	return self.point.y + textSize.height;
}



@end
