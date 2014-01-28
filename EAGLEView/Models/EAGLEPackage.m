//
//  EAGLEPackage.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEPackage.h"
#import "EAGLEDrawableObject.h"
#import "EAGLEDrawableText.h"
#import "DDXML.h"

@implementation EAGLEPackage

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
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
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:file];
			if( drawable )
				[tmpComponents addObject:drawable];
		}
		_components = [NSArray arrayWithArray:tmpComponents];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Package %@ - %d components", _name, (int)[_components count]];
}

- (void)drawInContext:(CGContextRef)context smashed:(BOOL)smashed mirrored:(BOOL)mirrored
{
	// Iterate and draw all components
	for( EAGLEDrawableObject *drawable in self.components )
		// If it's a text, check to see if we should set custom value
		if( [drawable isKindOfClass:[EAGLEDrawableText class]] )
		{
			NSString *placeholder = ((EAGLEDrawableText*)drawable).text;

			// Should this text be skipped (because it is smashed and the symbol object will draw it)?
			if( [self.placeholdersToSkip containsObject:placeholder] || smashed )
				// Yes: ignore this element
				continue;

			// Do we have a custom value for this text?
			if( self.textsForPlaceholders[ placeholder ] != nil )
				// Yes: set it
				[(EAGLEDrawableText*)drawable setValueText:self.textsForPlaceholders[ placeholder ]];

			// We need to call a special method since the text might need to be flipped
			[(EAGLEDrawableText*)drawable drawInContext:context flipText:NO isMirrored:NO];
		}
		else
		{
			// Draw it
			if( mirrored )
				[drawable drawOnBottomInContext:context];
			else
				[drawable drawInContext:context];
		}
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

- (CGFloat)maxX
{
	CGFloat maxX = -MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.components )
		maxX = MAX( maxX, [drawable maxX] );

	return maxX;
}

- (CGFloat)maxY
{
	CGFloat maxY = -MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.components )
		maxY = MAX( maxY, [drawable maxY] );

	return maxY;
}

- (CGFloat)minX
{
	CGFloat minX = MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.components )
		minX = MIN( minX, [drawable minX] );

	return minX;
}

- (CGFloat)minY
{
	CGFloat minY = MAXFLOAT;
	for( EAGLEDrawableObject *drawable in self.components )
		minY = MIN( minY, [drawable minY] );

	return minY;
}

@end
