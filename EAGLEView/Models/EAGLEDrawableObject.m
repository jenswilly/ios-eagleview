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
#import "DDXML.h"

@implementation EAGLEDrawableObject

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
		_layerNumber = @( [[[element attributeForName:@"layer"] stringValue] intValue] );

	return self;
}

+ (EAGLEDrawableObject*)drawableFromXMLElement:(DDXMLElement*)element inSchematic:(EAGLESchematic*)schematic
{
	NSString *elementName = [element localName];

	// Only use a wire object if there is no "curve" attribute
	if( [elementName isEqualToString:@"wire"] && [element attributeForName:@"curve"] == nil )
		return [[EAGLEDrawableWire alloc] initFromXMLElement:element inSchematic:schematic];

	// A "wire" _with_ a "curve" attribute is an arc
	if( [elementName isEqualToString:@"wire"] && [element attributeForName:@"curve"] != nil )
		return [[EAGLEDrawableArc alloc] initFromXMLElement:element inSchematic:schematic];

	if( [elementName isEqualToString:@"text"] )
		return [[EAGLEDrawableText alloc] initFromXMLElement:element inSchematic:schematic];

	if( [elementName isEqualToString:@"pin"] )
		return [[EAGLEDrawablePin alloc] initFromXMLElement:element inSchematic:schematic];

	if( [elementName isEqualToString:@"polygon"] )
		return [[EAGLEDrawablePolygon alloc] initFromXMLElement:element inSchematic:schematic];

	if( [elementName isEqualToString:@"circle"] )
		return [[EAGLEDrawableCircle alloc] initFromXMLElement:element inSchematic:schematic];

	// Unknown element name
	DEBUG_LOG( @"Unknown drawable element: %@", elementName );
	return nil;
}

- (void)setStrokeColorFromLayerInContext:(CGContextRef)context
{
	// Set color to layer's color
	EAGLELayer *currentLayer = self.schematic.layers[ self.layerNumber ];
	CGContextSetStrokeColorWithColor( context, [currentLayer.color CGColor] );
}

- (void)setFillColorFromLayerInContext:(CGContextRef)context
{
	// Set color to layer's color
	EAGLELayer *currentLayer = self.schematic.layers[ self.layerNumber ];
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
@end
