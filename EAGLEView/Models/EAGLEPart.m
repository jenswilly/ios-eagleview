//
//  EAGLEPart.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEPart.h"
#import "DDXML.h"

@implementation EAGLEPart
@synthesize name = _name;
@synthesize value = _value;

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file
{
	if( (self = [super initFromXMLElement:element inFile:file]) )
	{
		_name = [[element attributeForName:@"name"] stringValue];
		_value = [[element attributeForName:@"value"] stringValue];
		_library_name = [[element attributeForName:@"library"] stringValue];
		_deviceset_name = [[element attributeForName:@"deviceset"] stringValue];
		_device_name = [[element attributeForName:@"device"] stringValue];
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Part %@ - value: %@, library: %@, deviceset: %@, device: %@", self.name, self.value, self.library_name, self.deviceset_name, self.device_name];
}

- (NSString *)name
{
	if( _name == nil )
		return @"";
	else
		return _name;
}

- (NSString *)value
{
	if( _value == nil )
		return @"";
	else
		return _value;
}

@end
