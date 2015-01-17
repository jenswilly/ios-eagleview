//
//  EAGLEModuleInstance.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableModuleInstance.h"
#import "EAGLESchematic.h"
#import "EAGLESheet.h"
#import "EAGLEModule.h"
#import "EAGLEDrawableText.h"

#import "DDXML.h"

const CGFloat kModuleInstanceLineWidth = 0.8;

@implementation EAGLEDrawableModuleInstance
{
	NSString *_moduleName;
	EAGLEModule *_module;
}

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file] ))
	{
		// Hardcoded layer number 90
		_layerNumber = MODULE_INSTANCE_LAYER;

		CGFloat x = [[[element attributeForName:@"x"] stringValue] floatValue];
		CGFloat y = [[[element attributeForName:@"y"] stringValue] floatValue];
		_center = CGPointMake( x, y );

		NSString *rotationString = [[element attributeForName:@"rot"] stringValue];
		_rotation = [EAGLEDrawableObject rotationForString:rotationString];

		_name = [[element attributeForName:@"name"] stringValue];
		_moduleName = [[element attributeForName:@"module"] stringValue];

		// Note: we can't read the width and height just yet, because those are read from the <module> element which is not fully initialized yet.
		// Both properties will be lazily read from the module property.
	}

	return self;
}

- (EAGLEModule*)module
{
	if( _module == nil )
	{
		NSPredicate *findByName = [NSPredicate predicateWithFormat:@"name = %@", _moduleName];
		NSArray *found = [((EAGLESchematic*)self.file).modules filteredArrayUsingPredicate:findByName];
		_module = [found firstObject];
	}

	return _module;
}

- (void)drawInContext:(CGContextRef)context
{
	RETURN_IF_NOT_LAYER_VISIBLE;

	CGContextSaveGState( context );
	[super setStrokeColorFromLayerInContext:context];

	CGContextTranslateCTM( context, self.center.x, self.center.y );
	CGContextRotateCTM( context, [EAGLEDrawableObject radiansForRotation:self.rotation] );	// Now rotate. Otherwise, rotation center would be offset


	CGRect rect = CGRectMake( -self.width/2, -self.height/2, self.width, self.height );

	CGContextSetLineWidth( context, kModuleInstanceLineWidth );
	CGContextStrokeRect( context, rect );

	// Draw name label

	// Set font properties
	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = 0;

	NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:2.54 * kFontSizeFactor],
								  NSForegroundColorAttributeName: currentLayer.color,
								  NSParagraphStyleAttributeName: paragraphStyle };

	// Calculate text size and offset coordinate system
	NSString *stringToDraw = self.name;
	CGSize textSize = [stringToDraw sizeWithAttributes:attributes];
	CGContextTranslateCTM( context, -textSize.width/2, textSize.height + kTextYPadding );
	CGContextScaleCTM( context, 1, -1 );

	// Draw string
	[stringToDraw drawAtPoint:CGPointZero withAttributes:attributes];

	CGContextRestoreGState( context );
}

- (CGFloat)width
{
	return self.module.dx;
}

- (CGFloat)height
{
	return self.module.dy;
}

- (CGFloat)maxX
{
	return _center.x + self.width/2;
}

- (CGFloat)maxY
{
	return _center.y + self.height/2;
}

- (CGFloat)minX
{
	return _center.x - self.width/2;
}

- (CGFloat)minY
{
	return _center.y - self.height/2;
}

- (CGPoint)origin
{
	return _center;
}

- (CGRect)boundingRect
{
	return CGRectMake( [self minX], [self minY], self.width, self.height );
}


@end
