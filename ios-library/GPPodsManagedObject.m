//
//  GPPodsManagedObject.m
//  NHN
//
//  Created by Jens Willy Johannsen on 19/09/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPPodsManagedObject.h"
#import "GPAsyncURLConnection.h"
#import "GPCoreDataController.h"
#import "GPPods.h"
@implementation GPPodsManagedObject

+ (void)refreshFromServer:(void(^)(NSArray *currentItems, NSArray *deletedItems))completionBlock checkDeletedItems:(BOOL)checkDeletedItems errorBlock:(void(^)(NSError *error))errorBlock
{
	// Get URL to fetch JSON
	NSURL *url = [[GPPods sharedInstance] urlForAllEntriesForClass:[self class]];

	// Get JSON
	[GPAsyncURLConnection AsyncURLConnectionWithUrl:url userInfo:nil completeBlock:^(NSData *data, id userInfo) {

		// JSON loaded. Parse it
		NSError *error = nil;
		NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if( jsonArray && !error )
		{
			// Get all objects and iterate
			NSMutableArray *tmpItems = [NSMutableArray arrayWithCapacity:[jsonArray count]];
			for( NSDictionary *item in jsonArray )
			{
				// Create new Core Data item or fetch existing if an item with the same unique ID is already in the database
				GPPodsManagedObject *newItem = [self objectWithUniqueIDFromDictionary:item];

				// Configure with JSON dictionary
				[newItem configureWithJSONDictionary:item];

				// Add to array
				if( newItem )
					[tmpItems addObject:newItem];
			}

			// We're done getting current items. If we should *not* check for deleted items, we'll save MOM and call completion block now
			if( !checkDeletedItems )
			{
				NSError *error = nil;
				if( ![[GPCoreDataController sharedInstance].managedObjectContext save:&error] )
				{
					// Error occurred saving: pass it to the error block if it exists.
					if( errorBlock )
						errorBlock( error );
				}
				else
				{
					// No error, we're done. Call completion block if it exists with nil as deleted items since we're not checking for deleted items.
					if( completionBlock )
						completionBlock( [NSArray arrayWithArray:tmpItems], nil );
				}
			}
			else
			{
				// We *should* check for deleted items: get IDs for all current items
				NSMutableArray *currentIDs = [[NSMutableArray alloc] init];
				for( GPPodsManagedObject *currentObject in tmpItems )
				{
					// Extract the unique key from dictionary
					id uniqueID = [currentObject valueForKey:[self uniqueKey]];
					[currentIDs addObject:uniqueID];
				}

				// Select all items *not* in the list of current items
				// Fetch from Core Data and delete
				NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass( [self class] )];
				request.predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", [self uniqueKey], currentIDs];
				NSError *executeFetchError = nil;
				NSArray *foundObjects = [[GPCoreDataController sharedInstance].managedObjectContext executeFetchRequest:request error:&executeFetchError];

				if( executeFetchError )
				{
					// Error: pass it to the error block if it exists
					if( errorBlock )
						errorBlock( executeFetchError );
				}
				else
				{
					// No error: delete the found objects
					NSMutableArray *tmpDeletedObjects = [NSMutableArray arrayWithCapacity:[foundObjects count]];
					for( NSManagedObject *object in foundObjects )
					{
						[tmpDeletedObjects addObject:object];
						[[GPCoreDataController sharedInstance].managedObjectContext deleteObject:object];
					}

					// We're done: save the MOM (for both new/updated and deleted objects) and call completion block
					NSError *error = nil;
					if( ![[GPCoreDataController sharedInstance].managedObjectContext save:&error] )
					{
						// Error occurred saving: pass it to the error block if it exists.
						if( errorBlock )
							errorBlock( error );
					}
					else
					{
						// No error, we're done. Call completion block if it exists.
						if( completionBlock )
							completionBlock( [NSArray arrayWithArray:tmpItems], [NSArray arrayWithArray:tmpDeletedObjects] );
					}

				}

			}
		}

	} errorBlock:^(NSError *error) {

		// Error fetching from URL: pass the error to the error block if it exists
		if( errorBlock )
			errorBlock( error );
	}];
}

+ (NSDictionary *)mappings
{
	/* This class must be overridden.
	 * Return from this method a dictionary with model class property names as keys and id (^mapping)(NSDictionary *dictionary) blocks as the value.
	 * For example:
	 *
	 *		return @{ @"url": ^(NSDictionary *info) {return info[ @"url" ]; },
	 *				  @"name": ^(NSDictionary *info) {return info[ @"item_name" ]; }};
	 */

	[NSException raise:@"Abstraction error" format:@"The method '%@' must be overridden in class '%@'.", NSStringFromSelector( _cmd ), NSStringFromClass( [self class] )];
	return nil;
}

+ (NSString*)uniqueKey
{
	// Use ID as unique key by default. Override to use a different field.
	return @"ID";
}

- (void)setIsModified
{
	// Default implementation is empty. Override if you want to do something.
}

- (void)configureWithJSONDictionary:(NSDictionary *)dictionary
{
	BOOL isDirty = NO;

	// Iterate all keys in the mapping dictionary
	for( NSString *key in [[[self class] mappings] allKeys] )
	{
		// Get mapping block for this key
		id (^mapping)(NSDictionary *dictionary) = [[self class] mappings][ key ];

		// Run mapping block to get new value
		id value = mapping( dictionary );

		// Change from NSNull til nil
		if( value == [NSNull null] )
			value = nil;

		// Update value only if the values are different and they're not both nil (which will report NO to isEqual:)
		if( ![[self valueForKey:key] isEqual:value] && !([self valueForKey:key] == nil && value == nil) )
		{
			[self setValue:value forKey:key];

			// We're changed
			isDirty = YES;
		}
	}

	// Do we have changes?
	if( isDirty )
		// Yes: tell the object
		[self setIsModified];
}

+ (id)objectWithUniqueIDFromDictionary:(NSDictionary*)info
{
	// Make sure we have a non-nil unique key for this class
	NSAssert( [self uniqueKey], @"No unique key for class %@. Implement the uniqueKey method.", NSStringFromClass( [self class] ));

	// Extract the unique key from dictionary
	id (^mapping)(NSDictionary *dictionary) = [self mappings][ [self uniqueKey] ];
	id uniqueID = mapping( info );

	// Make a fetch request using unique key
    id object = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass( [self class] )];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", [self uniqueKey], uniqueID];
    NSError *executeFetchError = nil;
    object = [[[GPCoreDataController sharedInstance].managedObjectContext executeFetchRequest:request error:&executeFetchError] lastObject];

    if( executeFetchError )
		// Error: log it and nil will be returned
		NSLog( @"Error looking up %@ with id %@: %@", NSStringFromClass( [self class] ), uniqueID, [executeFetchError localizedDescription] );
	else if( !object )
		// Didn't find one: create a new one
        object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass( [self class] ) inManagedObjectContext:[GPCoreDataController sharedInstance].managedObjectContext];

    return object;
}

#pragma mark - Utility methods for saving/loading URLs, arrays and dictionaries as NSData

- (void)setURL:(NSURL*)url forKey:(NSString *)key
{
	[self willChangeValueForKey:key];
	NSData *data = nil;

	// If not nil, archive URL to NSData and set primitive data
	if( url != nil )
		data = [NSKeyedArchiver archivedDataWithRootObject:url];
	[self setPrimitiveValue:data forKey:key];
	[self didChangeValueForKey:key];
}

- (NSURL*)URLForKey:(NSString *)key
{
	[self willAccessValueForKey:key];
	NSURL *url = nil;

	// If primitive data is not nil, unarchive as NSURL.
	if( [self primitiveValueForKey:key] != nil )
		url = (NSURL*)[NSKeyedUnarchiver unarchiveObjectWithData:[self primitiveValueForKey:key]];
	[self didAccessValueForKey:key];

	return url;
}

// Utility methods for saving/loading NSArrays as NSData

- (void)setArray:(NSArray*)array forKey:(NSString *)key
{
	[self willChangeValueForKey:key];
	NSData *data = nil;

	// If not nil, archive array to NSData and set primitive data
	if( array != nil )
		data = [NSKeyedArchiver archivedDataWithRootObject:array];
	[self setPrimitiveValue:data forKey:key];
	[self didChangeValueForKey:key];
}

- (NSArray*)arrayForKey:(NSString *)key
{
	[self willAccessValueForKey:key];
	NSArray *array = nil;

	// If primitive data is not nil, unarchive as NSArray.
	if( [self primitiveValueForKey:key] != nil )
		array = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:[self primitiveValueForKey:key]];
	[self didAccessValueForKey:key];

	return array;
}

- (void)deleteAllObjects
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass( [self class] ) inManagedObjectContext:[GPCoreDataController sharedInstance].managedObjectContext];
	[fetchRequest setEntity:entity];

	NSError *error;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	for( NSManagedObject *managedObject in items )
		[self.managedObjectContext deleteObject:managedObject];

	if( ![self.managedObjectContext save:&error] )
		NSLog( @"Error deleting %@ - error:%@", NSStringFromClass( [self class] ),error );

#if DEBUG
	NSLog( @"Deleted all %@ objects", NSStringFromClass( [self class] ) );
#endif
}


// Utility methods for saving/loading NSDictionarys as NSData

- (void)setDictionary:(NSDictionary*)dictionary forKey:(NSString *)key
{
	[self willChangeValueForKey:key];
	NSData *data = nil;

	// If not nil, archive array to NSData and set primitive data
	if( dictionary != nil )
		data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	[self setPrimitiveValue:data forKey:key];
	[self didChangeValueForKey:key];
}

- (NSDictionary*)dictionaryForKey:(NSString *)key
{
	[self willAccessValueForKey:key];
	NSDictionary *dictionary = nil;

	// If primitive data is not nil, unarchive as NSArray.
	if( [self primitiveValueForKey:key] != nil )
		dictionary = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:[self primitiveValueForKey:key]];
	[self didAccessValueForKey:key];

	return dictionary;
}


@end
