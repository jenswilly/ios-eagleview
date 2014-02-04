//
//  EAGLEDrawable.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"
#import "EAGLESchematic.h"
#import "EAGLELayer.h"
#import "EAGLEDrawableText.h"
#import "EAGLEDrawableWire.h"
#import "EAGLEDrawablePin.h"
#import "EAGLEDrawablePolygon.h"
#import "EAGLEDrawableCircle.h"
#import "EAGLEDrawableArc.h"
#import "EAGLEDrawableRectangle.h"
#import "EAGLEDrawableFrame.h"
#import "EAGLEDrawablePad.h"
#import "EAGLEDrawableSmd.h"
#import "EAGLEDrawableVia.h"
#import "EAGLEDrawableHole.h"

#import "DDXML.h"

@implementation EAGLEDrawableObject

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_layerNumber = @( [[[element attributeForName:@"layer"] stringValue] intValue] );
	}

	return self;
}

+ (EAGLEDrawableObject*)drawableFromXMLElement:(DDXMLElement*)element inFile:(EAGLEFile *)file
{
	NSString *elementName = [element localName];

	// Only use a wire object if there is no "curve" attribute
	if( [elementName isEqualToString:@"wire"] && [element attributeForName:@"curve"] == nil )
		return [[EAGLEDrawableWire alloc] initFromXMLElement:element inFile:file];

	// A "wire" _with_ a "curve" attribute is an arc
	if( [elementName isEqualToString:@"wire"] && [element attributeForName:@"curve"] != nil )
		return [[EAGLEDrawableArc alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"text"] )
		return [[EAGLEDrawableText alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"pin"] )
		return [[EAGLEDrawablePin alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"polygon"] )
		return [[EAGLEDrawablePolygon alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"circle"] )
		return [[EAGLEDrawableCircle alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"rectangle"] )
		return [[EAGLEDrawableRectangle alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"frame"] )
		return [[EAGLEDrawableFrame alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"pad"] )
		return [[EAGLEDrawablePad alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"smd"] )
		return [[EAGLEDrawableSmd alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"via"] )
		return [[EAGLEDrawableVia alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"hole"] )
		return [[EAGLEDrawableHole alloc] initFromXMLElement:element inFile:file];

	if( [elementName isEqualToString:@"description"] )
		// Ignore description elements
		return nil;
	
	// Unknown element name
	DEBUG_LOG( @"Unknown drawable element: %@", elementName );
	return nil;
}

+ (BOOL)rotationIsMirrored:(Rotation)rotation
{
	return (rotation == Rotation_Mirror_MR0 || rotation == Rotation_Mirror_MR270 || rotation == Rotation_Mirror_MR180 || rotation == Rotation_Mirror_MR90 );
}

+ (CGFloat)radiansForRotation:(Rotation)rotation
{
	switch( rotation )
	{
		case Rotation_R45:
			return M_PI_4;

		case Rotation_R90:
		case Rotation_Mirror_MR90:
			return M_PI_2;

		case Rotation_R180:
			return M_PI;

		case Rotation_R225:
			return M_PI_4 * 5;

		case Rotation_R270:
		case Rotation_Mirror_MR270:
			return M_PI_2 * 3;

		case Rotation_Mirror_MR0:
			[NSException raise:@"Invalid rotation" format:@"This should be mirrored and not rotated!"];
			
		default:
			return 0;
	}
}

+ (Rotation)rotationForString:(NSString*)rotationString
{
	if( rotationString == nil || [rotationString isEqualToString:@"SR0"] )
		return Rotation_0;
	else if( [rotationString isEqualToString:@"R45"] )
		return Rotation_R45;
	else if( [rotationString isEqualToString:@"R90"] || [rotationString isEqualToString:@"SR90"] )
		return Rotation_R90;
	else if( [rotationString isEqualToString:@"R225"] )
		return Rotation_R225;
	else if( [rotationString isEqualToString:@"R270"] )
		return Rotation_R270;
	else if( [rotationString isEqualToString:@"R180"] )
		return Rotation_R180;
	else if( [rotationString isEqualToString:@"MR0"] )
		return Rotation_Mirror_MR0;
	else if( [rotationString isEqualToString:@"MR90"] )
		return Rotation_Mirror_MR90;
	else if( [rotationString isEqualToString:@"MR180"] )
		return Rotation_Mirror_MR180;
	else if( [rotationString isEqualToString:@"MR270"] )
		return Rotation_Mirror_MR270;
	else
		[NSException raise:@"Unknown rotation string" format:@"Unknown rotation: %@", rotationString];

	return 0;
}

+ (void)transformContext:(CGContextRef)context forRotation:(Rotation)rotation
{
	if( rotation == Rotation_Mirror_MR180 )
	{
		CGContextRotateCTM( context, [self radiansForRotation:rotation] );
	}
	else if( rotation == Rotation_Mirror_MR90 )
	{
		CGContextRotateCTM( context, [self radiansForRotation:rotation] );
		CGContextScaleCTM( context, 1, -1 );
	}
	else if( [self rotationIsMirrored:rotation] )
		// Mirror, not rotate
		CGContextScaleCTM( context, -1, 1 );
	else
		CGContextRotateCTM( context, [self radiansForRotation:rotation] );
}

- (PatternFncPtr)patternFunctionForLayer
{
	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];
	switch( [currentLayer.fillPatternNumber intValue] )
	{
		case 10:
			return &fillPattern10Function;

		default:
			return nil;
	}
}

void fillPattern10Function (void *info, CGContextRef context)
{
	UIColor *color = (__bridge UIColor*)info;

	CGContextSetFillColorWithColor( context, color.CGColor );
    CGContextAddArc( context, 3, 3, 4, 0, 2*M_PI, 0 );
    CGContextFillPath( context );

    CGContextAddArc( context, 16, 16, 4, 0, 2*M_PI, 0 );
    CGContextFillPath( context );
}



- (void)setStrokeColorFromLayerInContext:(CGContextRef)context
{
	// Set color to layer's color
	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];
	CGContextSetStrokeColorWithColor( context, [currentLayer.color CGColor] );
}

- (void)setFillColorFromLayerInContext:(CGContextRef)context
{
	// Set color to layer's color
	EAGLELayer *currentLayer = self.file.layers[ self.layerNumber ];
	CGContextSetFillColorWithColor( context, [currentLayer.color CGColor] );
}

- (void)drawInContext:(CGContextRef)context
{
	ABSTRACTION_ERROR;
}

/**
 * This method temporarily changes the layer if it is a top layer with a corresponding bottom layer and
 * then calls [self drawInContext:context] and then resets the layer number.
 */
- (void)drawOnBottomInContext:(CGContextRef)context
{
	// Override layer if necessary
	int layer = [self.layerNumber intValue];

	// Switch Top to Bottom layer
	if( layer == 1 )
		_layerNumber = @16;
	else if( layer == 21 || layer == 23 || layer == 25 || layer == 27 || layer == 29 || layer == 31 || layer == 33 || layer == 35 || layer == 37 || layer == 39 || layer == 41 || layer == 51 || layer == 105 || layer == 121 || layer == 123 || layer == 131 )
		// "top" layers prefixed by "t"
		_layerNumber = @( layer + 1 );

	[self drawInContext:context];

	// Reset layer
	_layerNumber = @( layer );
}

- (CGFloat)maxX
{
	ABSTRACTION_ERROR;
	return 0;
}

- (CGFloat)maxY
{
	ABSTRACTION_ERROR;
	return 0;
}

- (CGFloat)minX
{
	ABSTRACTION_ERROR;
	return 0;
}

- (CGFloat)minY
{
	ABSTRACTION_ERROR;
	return 0;
}

- (CGPoint)origin
{
	ABSTRACTION_ERROR;
	return CGPointZero;
}

- (CGRect)boundingRect
{
	ABSTRACTION_ERROR;
	return CGRectZero;
}


@end
