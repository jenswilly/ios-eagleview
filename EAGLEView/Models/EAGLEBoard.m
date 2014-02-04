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
#import "EAGLEPackage.h"
#import "EAGLEElement.h"
#import "EAGLESignal.h"

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

	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&err];
	if( err )
	{
		*error = err;
		return nil;
	}

	// Get board
	NSArray *boards = [xmlDocument nodesForXPath:@"/eagle/drawing/board" error:&err];
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
		*error = [NSError errorWithDomain:@"dk.greenerpastures.EAGLE" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"No board element found in file" }];
		return nil;
	}

	return board;
}

+ (instancetype)boardFromBoardFile:(NSString *)boardFileName error:(NSError *__autoreleasing *)error
{
	NSString *path = [[NSBundle mainBundle] pathForResource:boardFileName ofType:@"brd"];
	return [self boardFromBoardFileAtPath:path error:error];
}

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super initFromXMLElement:element]) )
	{
		NSError *error = nil;

		// Elements
		NSArray *elements = [element nodesForXPath:@"elements/element" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		NSMutableArray *tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			// Drawable
			EAGLEElement *element = [[EAGLEElement alloc] initFromXMLElement:childElement inFile:self];
			if( element )
				[tmpElements addObject:element];
		}

		// Sort elements so bottom elements are first. A mirrored object is considered a bottom element.
		[tmpElements sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			if( [EAGLEDrawableObject rotationIsMirrored:((EAGLEElement*)obj1).rotation] && ![EAGLEDrawableObject rotationIsMirrored:((EAGLEElement*)obj2).rotation] )
				return NSOrderedAscending;
			else
				return NSOrderedDescending;
		}];
		_elements = [NSArray arrayWithArray:tmpElements];

		// Signals
		elements = [element nodesForXPath:@"signals/signal" error:&error];
		EAGLE_XML_PARSE_ERROR_RETURN_NIL( error );
		tmpElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
		for( DDXMLElement *childElement in elements )
		{
			EAGLESignal *signal = [[EAGLESignal alloc] initFromXMLElement:childElement inFile:self];
			if( signal )
				[tmpElements addObject:signal];
		}
		_signals = [NSArray arrayWithArray:tmpElements];

		/// ...


		// Plain
		elements = [element nodesForXPath:@"plain/*" error:&error];
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

		// Extract drawables for each layer
		NSMutableDictionary *tmpDrawablesForLayers = [NSMutableDictionary dictionary];

		for( int layer = 0; layer < 255; layer++ )
		{
			BOOL hasElementDrawables = NO;

			NSMutableArray *tmpDrawablesForLayer = [NSMutableArray array];
			NSPredicate *layerPredicate = [NSPredicate predicateWithFormat:@"layerNumber = %@", @( layer )];

			// Signals contain both wires, polygons and vias
			for( EAGLESignal *signal in _signals )
			{
				[tmpDrawablesForLayer addObjectsFromArray:[signal.wires filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[signal.vias filteredArrayUsingPredicate:layerPredicate]];
				[tmpDrawablesForLayer addObjectsFromArray:[signal.polygons filteredArrayUsingPredicate:layerPredicate]];
			}

			// Elements
			for( EAGLEElement *element in _elements )
			{
				// If any element has components or smashed attributes on this layer we'll set the Boolean so we are sure to add an entry in the dictionary so we know what layer are "active"
				if( [[element.package.components filteredArrayUsingPredicate:layerPredicate] count] > 0 ||
				    [[[element.smashedAttributes allValues] filteredArrayUsingPredicate:layerPredicate] count] > 0 )
					hasElementDrawables = YES;
			}

			// Plain objects
			[tmpDrawablesForLayer addObjectsFromArray:[_plainObjects filteredArrayUsingPredicate:layerPredicate]];

			// Add objects if there are any (no need to have a bunch of empty arrays)
			if( [tmpDrawablesForLayer count] > 0 || hasElementDrawables )
				tmpDrawablesForLayers[ @(layer) ] = [NSArray arrayWithArray:tmpDrawablesForLayer];
		}
		_drawablesInLayers = [NSDictionary dictionaryWithDictionary:tmpDrawablesForLayers];
	}

	return self;
}

- (EAGLEPackage*)packageNamed:(NSString*)packageName inLibraryNamed:(NSString*)libraryName
{
	// Find library
	EAGLELibrary *library = [self libraryWithName:libraryName];

	return [library packageWithName:packageName];
}

@end
