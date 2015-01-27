//
//  GPJSONValidator.h
//  JSONValidation
//
//  Created by Jens Willy Johannsen on 21/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPJSONValidator : NSObject

+ (BOOL)validateJSONObject:(id)JSONObject withSchemaFileFromMainBundle:(NSString*)schemaFilename errorDescription:(NSString* __autoreleasing *)errorDescription;
+ (BOOL)validateJSONObject:(id)JSONObject withSchemaAtURL:(NSURL*)schemaURL errorDescription:(NSString* __autoreleasing *)errorDescription;

@end
