//
//  GPCoreDateController.m
//  iOS7 Test
//
//  Created by Jens Willy Johannsen on 21/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPCoreDataController.h"

@implementation GPCoreDataController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (GPCoreDataController*)sharedInstance
{
    static dispatch_once_t once;
    static GPCoreDataController *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)saveContext
{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

	// Make sure we have a MOM
	if( managedObjectContext )
	{
		if( [managedObjectContext hasChanges] && ![managedObjectContext save:&error] )
		{
			/// TODO: REPLACE WITH BETTER ERROR ALERT
			[NSException raise:@"Fatal Core Data error" format:@"Unable to save context: %@", [error userInfo]];
		}
	}
}

#pragma mark -
#pragma mark Core Data Stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext*)managedObjectContext
{
	// If already instantiated, return it immediately
	if( _managedObjectContext != nil )
		return _managedObjectContext;

	// Not instantiated: do it now
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if( coordinator != nil )
	{
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	}

	return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{
	// If already instantiated, return it immediately
	if( _managedObjectModel )
		return _managedObjectModel;

	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	// If already instantiated, return it immediately
	if( _persistentStoreCoordinator )
		return _persistentStoreCoordinator;

	// Get URL to sqlite db
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];

	// Initialize persistent store coordinator
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

	NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
									 NSInferMappingModelAutomaticallyOption: @YES };
	if( ![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error] )
	{
		// Couldn't open persist. First, see if we can fix it by deleting the store and re-creating it.
#if DEBUG
		NSLog( @"Error adding persistent store: %@. Attempting remove and re-create", [error localizedDescription] );
#endif

		// Delete the store and create it again if this is first attempt
		NSLog( @"Deleting persistent store" );
		NSError *fileError = nil;
		[[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&fileError];
		if( fileError != nil )
		{
#if DEBUG
			NSLog( @"Error removing data file: %@", [fileError localizedDescription] );
#endif
			goto error;
		}

		// File deleted – create it again
		error = nil;
#if DEBUG
		NSLog( @"Attempting to recreate persistent store" );
#endif
		if( ![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error] )
		{
#if DEBUG
			NSLog( @"Error recreating persistent store: %@", [error localizedDescription] );
#endif
			goto error;
		}

		/*
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
		 * [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		 *
		 * Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
		 *
		 */
	}

	return _persistentStoreCoordinator;

error:
	[NSException raise:@"Fatal Core Data error" format:@"Unable to initialize persistent store coordinator: %@", [error userInfo]];
	return nil;
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
