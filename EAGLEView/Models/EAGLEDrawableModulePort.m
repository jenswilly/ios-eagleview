//
//  EAGLEModulePort.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableModulePort.h"
#import "EAGLEDrawableModuleInstance.h"
#import "EAGLEFile.h"
#import "EAGLEDrawableText.h"
#import "DDXML.h"

static const CGFloat kModulePortSymbolLength = 5.08;	// Length of port "pin" symbol
static const CGFloat kModulePortTextSize = 1.27;
static const CGFloat kModulePortTextPadding = 1.27;

@implementation EAGLEDrawableModulePort

- (id)initFromXMLElement:(DDXMLElement*)element inFile:(EAGLEFile*)file
{
	if( (self = [super init] ))
	{
		_file = file;
		_name = [[element attributeForName:@"name"] stringValue];
		_position = [[[element attributeForName:@"coord"] stringValue] floatValue];

		NSString *sideString = [[element attributeForName:@"side"] stringValue];
		if( [[sideString lowercaseString] isEqualToString:@"left"] )
			_side = EAGLEModulePortSideLeft;
		else if( [[sideString lowercaseString] isEqualToString:@"right"] )
			_side = EAGLEModulePortSideRight;
		else if( [[sideString lowercaseString] isEqualToString:@"top"] )
			_side = EAGLEModulePortSideTop;
		else if( [[sideString lowercaseString] isEqualToString:@"bottom"] )
			_side = EAGLEModulePortSideBottom;

		NSString *directionString = [[element attributeForName:@"direction"] stringValue];
		if( [[directionString lowercaseString] isEqualToString:@"io"] )
			_direction = EAGLEModulePortDirectionIO;
		else
		{
			DEBUG_LOG( @"Unknown module port direction: %@", directionString );
			_direction = EAGLEModulePortDirectionOther;
		}
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Module port %@", self.name];
}

- (void)drawInContext:(CGContextRef)context moduleInstance:(EAGLEDrawableModuleInstance*)moduleInstance
{
	/// TODO: implement drawing of port.
	CGContextSaveGState( context );

	// Calculate text size so we can set offset correctly.
	EAGLELayer *currentLayer = self.file.layers[ @95 ];	// Use layer 95 (names) to get color
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:kModulePortTextSize * kFontSizeFactor],
								  NSForegroundColorAttributeName: currentLayer.color,
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	NSString *stringToDraw = self.name;
	CGSize textSize = [stringToDraw sizeWithAttributes:attributes];

	// Offset context and set length of symbol based on side and position
	CGPoint vector;
	CGPoint textOffset;
	Rotation textRotation;
	switch( self.side )
	{
		case EAGLEModulePortSideLeft:
			CGContextTranslateCTM( context, -moduleInstance.width/2, self.position );
			vector = CGPointMake( -kModulePortSymbolLength, 0 );
			textOffset = CGPointMake( kModulePortTextPadding, textSize.height/2 );
			textRotation = Rotation_0;
			break;

		case EAGLEModulePortSideRight:
			CGContextTranslateCTM( context, moduleInstance.width/2, self.position );
			vector = CGPointMake( kModulePortSymbolLength, 0 );
			textOffset = CGPointMake( -kModulePortTextPadding - textSize.width, textSize.height/2 );
			textRotation = Rotation_0;
			break;

		case EAGLEModulePortSideTop:
			CGContextTranslateCTM( context, self.position, moduleInstance.height/2 );
			vector = CGPointMake( 0, kModulePortSymbolLength );
			textOffset = CGPointMake( textSize.height/2, -kModulePortTextPadding );
			textRotation = Rotation_R90;
			break;

		case EAGLEModulePortSideBottom:
			CGContextTranslateCTM( context, self.position, -moduleInstance.height/2 );
			vector = CGPointMake( 0, -kModulePortSymbolLength );
			textOffset = CGPointMake( textSize.height/2, textSize.width + kModulePortTextPadding );
			textRotation = Rotation_R90;
			break;
	}

	// Line width is already set in module instance drawing.
	CGContextSetLineCap( context, kCGLineCapRound );
	CGContextMoveToPoint( context, 0, 0 );
	CGContextAddLineToPoint( context, vector.x, vector.y );
	CGContextStrokePath( context );

	// Draw port label.
	CGContextTranslateCTM( context, textOffset.x, textOffset.y );
	CGContextScaleCTM( context, 1, -1 );
	CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:textRotation] );
	[stringToDraw drawAtPoint:CGPointZero withAttributes:attributes];

	CGContextRestoreGState( context );
}

@end
