//
//  EAGLEModulePort.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLEModulePort.h"
#import "DDXML.h"

@implementation EAGLEModulePort

- (id)initFromXMLElement:(DDXMLElement*)element
{
	if( (self = [super init] ))
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_position = [[[element attributeForName:@"coord"] stringValue] floatValue];

		NSString *sideString = [[element attributeForName:@"side"] stringValue];
		if( [[sideString lowercaseString] isEqualToString:@"left"] )
			_side = EAGLEModulePortSideLeft;
		else if( [[sideString lowercaseString] isEqualToString:@"right"] )
			_side = EAGLEModulePortSideRight;
		else if( [[sideString lowercaseString] isEqualToString:@"top"] )
			_side = EAGLEModulePortSideTop;
		else if( [[sideString lowercaseString] isEqualToString:@"bottom"] )
			_side = EAGLEModulePortSideBottom;

		NSString *directionString = [[element attributeForName:@"direction"] stringValue];
		if( [[directionString lowercaseString] isEqualToString:@"io"] )
			_direction = EAGLEModulePortDirectionIO;
		else
		{
			DEBUG_LOG( @"Unknown module port direction: %@", directionString );
			_direction = EAGLEModulePortDirectionOther;
		}
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Module port %@", self.name];
}

- (void)drawInContext:(CGContextRef)context
{

}

@end
