//
//  EAGLEAttribute.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEAttribute.h"
#import "DDXML.h"
#import "EAGLEDrawableText.h"	// For kFontSizeFactor
#import "EAGLELayer.h"
#import "EAGLEFile.h"

static const CGFloat kAttributeTextYPadding = -0.4f;

@implementation EAGLEAttribute

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_point = CGPointMake( x, y );

		_size = [[[element attributeForName:@"size"] stringValue] floatValue];

		NSString *rotString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotString];
}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Attribute %@ - at %@, size %.2f", self.name, NSStringFromCGPoint( self.point ), self.size];
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	// Flip and translate coordinate system for text drawing
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, self.point.x, self.point.y );
	[EAGLEDrawableObject transformContext:context forRotation:self.rotation];

	// Set color
	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];

	// Set font properties
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor],
								  NSForegroundColorAttributeName: currentLayer.color,
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	CGSize textSize = [self.text sizeWithAttributes:attributes];
	CGContextTranslateCTM( context, 0, textSize.height + kAttributeTextYPadding );
	CGContextScaleCTM( context, 1, -1 );

	if( _rotation == Rotation_R180 || _rotation == Rotation_R225 )
	{
		CGContextTranslateCTM( context, textSize.width, textSize.height );
		CGContextScaleCTM( context, -1, -1 );
	}

	// Draw string
	[self.text drawAtPoint:CGPointZero withAttributes:attributes];

	CGContextRestoreGState( context );
}

- (CGFloat)maxX
{
	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor] };
	CGSize textSize = [self.text sizeWithAttributes:attributes];

	// Rotate if necessary
	UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, textSize.width, textSize.height )];
	if( self.rotation != Rotation_Mirror_MR0 )
		dummyView.transform = CGAffineTransformMakeRotation( [EAGLEDrawableObject radiansForRotation:self.rotation] );

	return self.point.x + dummyView.bounds.size.width;
}

- (CGFloat)maxY
{
	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:self.size * kFontSizeFactor] };
	CGSize textSize = [self.text sizeWithAttributes:attributes];

	// Rotate if necessary
	UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, textSize.width, textSize.height )];
	if( self.rotation != Rotation_Mirror_MR0 )
		dummyView.transform = CGAffineTransformMakeRotation( [EAGLEDrawableObject radiansForRotation:self.rotation] );

	return self.point.y + dummyView.bounds.size.height;
}

- (CGFloat)minX
{
	return self.point.x;
}

- (CGFloat)minY
{
	return self.point.y;
}

@end
