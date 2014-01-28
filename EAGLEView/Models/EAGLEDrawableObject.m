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

#import "DDXML.h"

@implementation EAGLEDrawableObject

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
		_layerNumber = @( [[[element attributeForName:@"layer"] stringValue] intValue] );

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

	// Unknown element name
	DEBUG_LOG( @"Unknown drawable element: %@", elementName );
	return nil;
}

+ (CGFloat)radiansForRotation:(Rotation)rotation
{
	switch( rotation )
	{
		case Rotation_R45:
			return M_PI_4;

		case Rotation_R90:
			return M_PI_2;

		case Rotation_R180:
			return M_PI;

		case Rotation_R225:
			return M_PI_4 * 5;

		case Rotation_R270:
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
	else if( [rotationString isEqualToString:@"R90"] )
		return Rotation_R90;
	else if( [rotationString isEqualToString:@"R225"] )
		return Rotation_R225;
	else if( [rotationString isEqualToString:@"R270"] )
		return Rotation_R270;
	else if( [rotationString isEqualToString:@"R180"] || [rotationString isEqualToString:@"MR180"] )
		return Rotation_R180;
	else if( [rotationString isEqualToString:@"MR0"] )
		return Rotation_Mirror_MR0;
	else
		[NSException raise:@"Unknown rotation string" format:@"Unknown rotation: %@", rotationString];

	return 0;
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
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
}

- (CGFloat)maxX
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return 0;
}

- (CGFloat)maxY
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return 0;
}

- (CGFloat)minX
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return 0;
}

- (CGFloat)minY
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return 0;
}

- (CGPoint)origin
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return CGPointZero;
}

- (CGRect)boundingRect
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return CGRectZero;
}


@end
