//
//  EAGLEBoard.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEBoard.h"
#import "DDXML.h"
#import "EAGLELibrary.h"
#import "EAGLELayer.h"
#import "EAGLEDrawableObject.h"

@implementation EAGLEBoard

+ (instancetype)boardFromBoardFileAtPath:(NSString*)path error:(NSError *__autoreleasing *)error
{
	NSError *err = nil;
	NSURL *fileURL = [NSURL fileURLWithPath:path];
	NSData *xmlData = [NSData dataWithContentsOfURL:fileURL options:0 error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Get board
	NSArray *boards = [xmlDocument nodesForXPath:@"/eagle/drawing/board" error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	EAGLEBoard *board = nil;
	if( [boards count] > 0 )
		board = [[EAGLEBoard alloc] initFromXMLElement:boards[ 0 ]];
	else
	{
		// Set reference to error
		if( error )
			*error = [NSError errorWithDomain:@"dk.greenerpastures.EAGLE" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"No board element found in file" }];
		return nil;
	}

	// Get layers
	NSArray *layers = [xmlDocument nodesForXPath:@"/eagle/drawing/layers/layer" error:error];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Iterate and initialize objects
	NSMutableDictionary *tmpLayers = [[NSMutableDictionary alloc] initWithCapacity:[layers count]];
	for( DDXMLElement *element in layers )
	{
		EAGLELayer *layer = [[EAGLELayer alloc] initFromXMLElement:element inFile:board];
		if( layer )
			tmpLayers[ layer.number ] = layer;
	}
	board.layers = [NSDictionary dictionaryWithDictionary:tmpLayers];

	return board;
}

+ (instancetype)boardFromBoardFile:(NSString *)boardFileName error:(NSError *__autoreleasing *)error
{
	NSString *path = [[NSBundle mainBundle] pathForResource:boardFileName ofType:@"brd"];
	return [self boardFromBoardFileAtPath:path error:error];
}

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super init]) )
	{
		NSError *error = nil;

		// Libraries
		NSArray *elements = [element nodesForXPath:@"libraries/library" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );

		// Iterate and initialize objects
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLELibrary *library = [[EAGLELibrary alloc] initFromXMLElement:childElement inFile:self];
			if( library )
				[tmpElements addObject:library];
		}
		_libraries = [NSArray arrayWithArray:tmpElements];
		
		/// ...

		// Plain
		elements = [element nodesForXPath:@"sheets/sheet/plain/*" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			// Drawable
			EAGLEDrawableObject *drawable = [EAGLEDrawableObject drawableFromXMLElement:childElement inFile:self];
			if( drawable )
				[tmpElements addObject:drawable];
		}
		_plainObjects = [NSArray arrayWithArray:tmpElements];

	}

	return self;
}


@end
