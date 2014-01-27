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

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super init]) )
		_file = file;	// Keep (weak) pointer to file (schematic/board)

	return self;
}

// Returns self.file typecasted to an EAGLESchematic object
- (EAGLESchematic *)schematic
{
	return (EAGLESchematic*)_file;
}

// Returns self.file typecasted to an EAGLEBoard object
- (EAGLEBoard *)board
{
	return (EAGLEBoard*)_file;
}

@end
