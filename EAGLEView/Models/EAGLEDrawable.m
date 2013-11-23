//
//  EAGLEDrawable.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawable.h"
#import "EAGLEDrawableText.h"
#import "EAGLEDrawableWire.h"
#import "DDXML.h"

@implementation EAGLEDrawable

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
		_layerNumber = @( [[[element attributeForName:@"layer"] stringValue] intValue] );

	return self;
}

+ (EAGLEDrawable*)drawableFromXMLElement:(DDXMLElement*)element inSchematic:(EAGLESchematic*)schematic
{
	NSString *elementName = [element localName];

	if( [elementName isEqualToString:@"wire"] )
		return [[EAGLEDrawableWire alloc] initFromXMLElement:element inSchematic:schematic];

	if( [elementName isEqualToString:@"text"] )
		return [[EAGLEDrawableText alloc] initFromXMLElement:element inSchematic:schematic];

	// Unknown element name
	return nil;
}

- (void)drawInContext:(CGContextRef)context
{
	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
}

@end
