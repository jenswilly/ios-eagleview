//
//  GPStorageRoom.m
//  iOS7 Test
//
//  Created by Jens Willy Johannsen on 21/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPStorageRoom.h"

// Base URL for all API calls
static NSString *const kGPStorageRoomAPIServer = @"api.storageroomapp.com";

@implementation GPStorageRoom
{
	NSMutableDictionary *_classesCollectionsDictionary;	// Keeps associations between class names and collection IDs. Use -[GPStorageRoom registerCollectionID:forClass:] to register collection IDs.
}

+ (GPStorageRoom*)sharedInstance
{
    static dispatch_once_t once;
    static GPStorageRoom *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
	if( (self = [super init]) )
	{
		// Initialize classes-collections dictionary
		_classesCollectionsDictionary = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (NSURL*)urlForAllEntriesInCollection:(NSString*)collectionID
{
	// Make sure account ID and authentication token are set
	if( [_accountID length] == 0 || [_authToken length] == 0 )
		return nil;

	// Construct URL string. NB: change meta prefix to underscore so we can use valueForKeyPath: to retrieve nested properties
	NSString *urlString = [NSString stringWithFormat:@"http://%@/accounts/%@/collections/%@/entries.json?auth_token=%@&per_page=999&meta_prefix=_", kGPStorageRoomAPIServer, _accountID, collectionID, _authToken];
	return [NSURL URLWithString:urlString];
}

- (NSURL*)urlForAllEntriesForClass:(Class)class
{
	// Make sure account ID and authentication token are set
	if( [_accountID length] == 0 || [_authToken length] == 0 )
		return nil;

	// Get collection ID for class
	NSString *collectionID = [_classesCollectionsDictionary objectForKey:NSStringFromClass(class)];

	// Return nil if no collection ID found
	if( !collectionID )
		return nil;

	// Return URL for collection ID
	return [self urlForAllEntriesInCollection:collectionID];
}


- (NSURL*)urlForDeletedEntriesInCollection:(NSString*)collectionID
{
	// Make sure account ID and authentication token are set
	if( [_accountID length] == 0 || [_authToken length] == 0 )
		return nil;

	// http://api.storageroomapp.com/accounts/51c40fc00f66026428000c2b/deleted_entries.json?collection_url=http%3A%2F%2Fapi.storageroomapp.com%2Faccounts%2F51c40fc00f66026428000c2b%2Fcollections%2F51c41fc80f660264040010ed&auth_token=ddX4R4mrCVpV1nHBskCm&meta_prefix=_
	// Construct URL string. NB: change meta prefix to underscore so we can use valueForKeyPath: to retrieve nested properties.
	// Also note that the http:// and /'s in the collection_url has already been escaped.
	// And: we append a unique UUID in order to avoid the hard caching of the deleted_entries. (See this post: http://help.storageroomapp.com/discussions/questions/1950-syncing-without-using-storageroomkit)
	NSString *unique = [[NSUUID UUID] UUIDString];
	NSString *urlString = [NSString stringWithFormat:@"http://%1$@/accounts/%2$@/deleted_entries.json?collection_url=http%%3A%%2F%%2F%1$@%%2Faccounts%%2F%2$@%%2Fcollections%%2F%3$@&auth_token=%4$@&meta_prefix=_&_=%5$@", kGPStorageRoomAPIServer, _accountID, collectionID, _authToken, unique];
	return [NSURL URLWithString:urlString];
}

- (NSURL*)urlForDeletedEntriesForClass:(Class)class
{
	// Make sure account ID and authentication token are set
	if( [_accountID length] == 0 || [_authToken length] == 0 )
		return nil;

	// Get collection ID for class
	NSString *collectionID = [_classesCollectionsDictionary objectForKey:NSStringFromClass(class)];

	// Return nil if no collection ID found
	if( !collectionID )
		return nil;

	// Return deleted entries URL for collection
	return [self urlForDeletedEntriesInCollection:collectionID];
}

- (void)registerCollectionID:(NSString*)collectionID forClass:(Class)class
{
	// Insert (or overwrite) collection ID for class
	[_classesCollectionsDictionary setObject:collectionID forKey:NSStringFromClass(class)];
}


@end
