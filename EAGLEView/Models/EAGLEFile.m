//
//  EAGLEFile.m
//  
//
//  Created by Jens Willy Johannsen on 27/01/14.
//
//

#import "EAGLEFile.h"
#import "EAGLELibrary.h"
#import "EAGLELayer.h"
#import "DDXML.h"

@implementation EAGLEFile

- (id)initFromXMLElement:(DDXMLElement *)element
{
	if( (self = [super init]) )
	{
		// Get layers
		NSError *error = nil;
		NSArray *layers = [element nodesForXPath:@"../layers/layer[ @active=\"yes\" ]" error:&error];
		if( error )
			return nil;

		// Iterate and initialize layers
		NSMutableDictionary *tmpLayers = [[NSMutableDictionary alloc] initWithCapacity:[layers count]];
		for( DDXMLElement *element in layers )
		{
			EAGLELayer *layer = [[EAGLELayer alloc] initFromXMLElement:element inFile:self];
			if( layer )
				tmpLayers[ layer.number ] = layer;
		}
		_layers = [NSDictionary dictionaryWithDictionary:tmpLayers];

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
		
}

	return self;
}

- (EAGLELibrary *)libraryWithName:(NSString *)name
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found = [self.libraries filteredArrayUsingPredicate:predicate];
	if( [found count] > 0 )
		return found[ 0 ];
	else
		return nil;
}

- (NSString*)dateString
{
	// If no date has been set, return an empty string
	if( !self.fileDate )
		return @"";

	// Substitute file's date
	static NSDateFormatter *dateFormatter = nil;
	if( dateFormatter == nil )
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"dd/MM/yy HH.mm";
	}
	return [dateFormatter stringFromDate:self.fileDate];
}

- (BOOL)allTopLayersVisible
{
	NSPredicate *relevantLayersFilter = [NSPredicate predicateWithFormat:@"number IN %@", TOP_LAYERS];
	NSArray *relevantLayers = [[self.layers allValues] filteredArrayUsingPredicate:relevantLayersFilter];
	for( EAGLELayer *layer in relevantLayers )
		if( !layer.visible )
			return NO;

	// Fall-through: all layers are visible
	return YES;
}

- (BOOL)allBottomLayersVisible
{
	NSPredicate *relevantLayersFilter = [NSPredicate predicateWithFormat:@"number IN %@", BOTTOM_LAYERS];
	NSArray *relevantLayers = [[self.layers allValues] filteredArrayUsingPredicate:relevantLayersFilter];
	for( EAGLELayer *layer in relevantLayers )
		if( !layer.visible )
			return NO;

	// Fall-through: all layers are visible
	return YES;
}

@end
