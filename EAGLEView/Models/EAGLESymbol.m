//
//  EAGLESymbol.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLESymbol.h"
#import "DDXML.h"
#import "EAGLEDrawable.h"

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
			EAGLEDrawable *drawable = [EAGLEDrawable drawableFromXMLElement:childElement inSchematic:schematic];
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
	
}

- (UIImage*)image
{
	UIGraphicsBeginImageContextWithOptions( CGSizeMake( 200, 200 ), NO, [UIScreen mainScreen].scale );
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Fix the coordinate system so 0,0 is at bottom-left
	CGContextTranslateCTM( context, 100, 100 );

	// Set zoom level
	CGContextScaleCTM( context, 10, 10 );

	// Iterate drawables
	for( EAGLEDrawable *drawable in self.components )
	{
		[drawable drawInContext:context];
	}
	
	// Get the image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

@end
