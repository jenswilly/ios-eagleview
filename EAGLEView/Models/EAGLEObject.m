//
//  EAGLEObject.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "TBXML.h"

@implementation EAGLEObject

+ (NSArray *)layersFromSchematicFile:(NSString *)schematicFileName error:(NSError *__autoreleasing *)error
{
	TBXML *xml = [[TBXML alloc] initWithXMLFile:schematicFileName fileExtension:@"sch" error:error];

	[TBXML iterateElementsForQuery:@"eagle.drawing.layers" fromElement:xml.rootXMLElement withBlock:^(TBXMLElement *element) {

		DEBUG_LOG( @"Layer: %@", [TBXML elementName:element] );
	}];

	return nil;
}
@end
