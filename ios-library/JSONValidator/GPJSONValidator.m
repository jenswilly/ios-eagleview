//
//  GPJSONValidator.m
//  JSONValidation
//
//  Created by Jens Willy Johannsen on 21/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPJSONValidator.h"
#import "CBLJSONValidator.h"

@implementation GPJSONValidator

+ (BOOL)validateJSONObject:(id)JSONObject withSchemaFileFromMainBundle:(NSString*)schemaFilename errorDescription:(NSString* __autoreleasing *)errorDescription
{
	NSURL* url = [[NSBundle mainBundle] URLForResource:@"person_schema" withExtension: @"json"];
	return [self validateJSONObject:JSONObject withSchemaAtURL:url errorDescription:errorDescription];
}

+ (BOOL)validateJSONObject:(id)JSONObject withSchemaAtURL:(NSURL*)schemaURL errorDescription:(NSString* __autoreleasing *)errorDescription
{
    NSError* error;
    CBLJSONValidator* validator = [CBLJSONValidator validatorForSchemaAtURL:schemaURL error: &error];
#if DEBUG
    NSAssert( validator != nil, @"Couldn't load JSON validator: %@", error);
    NSAssert( [validator selfValidate: &error], @"Validator is invalid: %@", error);
#endif

	// Raise exception if schema could not be loaded
	if( validator == nil )
		[NSException raise:@"Unable to load JSON schema" format:@"Error loading schema: %@", [error localizedDescription]];

	BOOL isValid = [validator validateJSONObject:JSONObject error:&error];
#if DEBUG
	NSAssert( isValid, @"JSON not valid: %@ – %@", error.userInfo[ @"path" ], [error localizedDescription] );
#endif

	// If not valid, create an error description string
	if( !isValid && errorDescription )
		*errorDescription = [NSString stringWithFormat:@"%@ – %@", error.userInfo[ @"path" ], [error localizedDescription]];

	return isValid;
}

@end
