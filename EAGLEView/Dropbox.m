//
//  Dropbox.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "Dropbox.h"
#import "AppDelegate.h"

NSString* const kDropboxFolderName = @"dropbox";
typedef void(^genericBlock_t)(BOOL success, id contents, DBMetadata *metadata);	// This can be used for both folder and file completion blocks

@implementation Dropbox
{
	DBRestClient *_restClient;
	NSMutableDictionary *_contents;	// Cached contents dirctory. Key is the path.
	BOOL _isBusy;
	genericBlock_t _completionBlock;
}

+ (Dropbox*)sharedInstance
{
    static dispatch_once_t once;
    static Dropbox *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
	if( (self = [super init]) )
	{
		// Initialize restClient
//		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//		_restClient.delegate = self;

		// Dictionary for holding files and folders
		_contents = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (DBRestClient*)restClient
{
	if( _restClient == nil )
	{
		DEBUG_LOG( @"Initializing RestClient" );
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}

	return _restClient;
}

- (BOOL)isBusy
{
	return _isBusy;
}

- (void)reset
{
	// Clear old content
	_restClient = nil;
	_contents = nil;

	// Start new session (for authentication to work properly)
//	DBSession* dbSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
//	[DBSession setSharedSession:dbSession];

	// Re-initialize REST client and cache
//	_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//	_restClient.delegate = self;
	_contents = [[NSMutableDictionary alloc] init];
}

- (BOOL)hasCachedContentsForFolder:(NSString*)path
{
	@synchronized( self )
	{
		if( path == nil )
			path = @"/";
		
		return ( _contents[ [path lowercaseString] ] ? YES : NO );
	}
}

- (BOOL)loadContentsForFolder:(NSString*)path completion:(foldercompletionBlock_t)completion
{
	@synchronized( self )
	{
		// Do we already have contents for the specified folder path?
		if( _contents[ [path lowercaseString] ] )
		{
			// Yes: return it immediately in the completion block
			completion( YES, _contents[ [path lowercaseString] ], nil );
			return YES;
		}
		
		// Return NO if already busy
		if( _isBusy )
			return NO;

		// Remember completion block
		_completionBlock = completion;

		// Start loading
		_isBusy = YES;
		[[self restClient] loadMetadata:path];
		return YES;
	}
}

- (BOOL)loadFileAtPath:(NSString*)path completion:(fileCompletionBlock_t)completion
{
	// Return NO if already busy
	if( _isBusy )
		return NO;

	// Remember completion block
	_completionBlock = completion;

	// Construct local path. First get documents path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dropboxFolderPath = paths[0];

	// Append Dropbox folder path and path to file (but remove filename)
	dropboxFolderPath = [dropboxFolderPath stringByAppendingPathComponent:kDropboxFolderName];
	dropboxFolderPath = [dropboxFolderPath stringByAppendingPathComponent:path];
	dropboxFolderPath = [dropboxFolderPath stringByDeletingLastPathComponent];

	// Make sure the folder exists
	if( ![[NSFileManager defaultManager] fileExistsAtPath:dropboxFolderPath] )
	{
		DEBUG_LOG( @"Creating folder at %@", dropboxFolderPath );
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:dropboxFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
		NSAssert( error == nil, @"Error creating documents folder: %@", [error localizedDescription] );
	}

	// Re-append last path component so the loaded file doesn't have the name of its parent directory.
	dropboxFolderPath = [dropboxFolderPath stringByAppendingPathComponent:[path lastPathComponent]];
	// Start loading
	_isBusy = YES;
	[[self restClient] loadFile:path intoPath:dropboxFolderPath];
	return YES;
}

#pragma mark - Rest client delegate methods

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata
{
	DEBUG_LOG( @"File loaded into path: %@", localPath );
	_completionBlock( YES, localPath, metadata );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
	DEBUG_LOG( @"There was an error loading the file - %@", [error localizedDescription] );
	_completionBlock( NO, nil, nil );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
	// If the folder is deleted, we'll consider it non-existing
	if( metadata.isDeleted )
	{
		_completionBlock( NO, nil, nil );
		_isBusy = NO;
		return;
	}
	
	// Set contents
	_contents[ [metadata.path lowercaseString] ] = metadata.contents;

	// Call completion block
	_completionBlock( YES, metadata.contents, metadata );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
	DEBUG_LOG( @"Error loading metadata: %@", [error localizedDescription] );
	_completionBlock( NO, nil, nil );
	_isBusy = NO;
}

@end
