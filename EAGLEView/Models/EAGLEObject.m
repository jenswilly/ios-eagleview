//
//  EAGLEObject.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "DDXML.h"
#import "EAGLEDrawableWire.h"
#import "EAGLEDrawableText.h"
#import "EAGLESchematic.h"

@implementation EAGLEObject

- (id)initFromXMLElement:(DDXMLElement *)element
{
	// Exception if calling -[EAGLEObject initFromXMLElement:]
	if( [self isKindOfClass:[EAGLEObject class]] )
		[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in subclass.", NSStringFromSelector( _cmd )];
	else
		// Exception is calling initFromXMLElement: from subclass where method is not overridden.
		[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];

	return nil;
}

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super init]) )
	{
		_schematic = schematic;	// Keep (weak) pointer to schematic
	}

	return self;
}

@end
