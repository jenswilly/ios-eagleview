//
//  EAGLESymbol.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLESymbol.h"
#import "DDXML.h"
#import "EAGLEDrawableObject.h"

@implementation EAGLESymbol

- (id)initFromXMLElement:(DDXMLElement *)element inSchematic:(EAGLESchematic *)schematic
{
	if( (self = [super initFromXMLElement:element inSchematic:schematic]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];

		// Components
		NSError *error = nil;
		NSArray *components = [element nodesForXPath:@"*" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		NSMutableArray *tmpComponents = [[NSMutableArray alloc] initWithCapacity:[components count]];
		for( DDXMLElement *childElement in components )
		{
			// Drawable
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inSchematic:schematic];
			if( drawable )
				[tmpComponents addObject:drawable];
		}
		_components = [NSArray arrayWithArray:tmpComponents];

	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Symbol %@, components: %@", self.name, [self.components description]];
}

- (void)drawAtPoint:(CGPoint)origin context:(CGContextRef)context
{
	// Offset to point
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, origin.x, origin.y );

	// Iterate and draw all components
	for( EAGLEDrawableObject *drawable in self.components )
		[drawable drawInContext:context];

	// Restore coordinate system
	CGContextRestoreGState( context );
}

@end
