//
//  Dropbox.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "Dropbox.h"

static NSString* const kDropboxFolderName = @"dropbox";
typedef void(^genericBlock_t)(BOOL success, id contents);	// This can be used for both folder and file completion blocks

@implementation Dropbox
{
	DBRestClient *_restClient;
	NSMutableDictionary *_contents;
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
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;

		// Dictionary for holding files and folders
		_contents = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (BOOL)isBusy
{
	return _isBusy;
}

- (BOOL)hasCachedContentsForFolder:(NSString*)path
{
	return ( _contents[ path ] ? YES : NO );
}

- (BOOL)loadContentsForFolder:(NSString*)path completion:(foldercompletionBlock_t)completion
{
	// Do we already have contents for the specified folder path?
	if( _contents[ path ] )
	{
		// Yes: return it immediately in the completion block
		DEBUG_LOG( @"Contents already loaded for %@", path );
		completion( YES, _contents[ path ] );
		return YES;
	}
	
	// Return NO if already busy
	if( _isBusy )
		return NO;

	// Remember completion block
	_completionBlock = completion;

	// Start loading
	_isBusy = YES;
	[_restClient loadMetadata:path];
	return YES;
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
		DEBUG_LOG( @"Creating documents folder at %@", dropboxFolderPath );
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:dropboxFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
		NSAssert( error == nil, @"Error creating documents folder: %@", [error localizedDescription] );
	}

	// Append path

	// Start loading
	_isBusy = YES;
	[_restClient loadFile:path intoPath:dropboxFolderPath];
	return YES;
}

#pragma mark - Rest client delegate methods

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata
{
	DEBUG_LOG( @"File loaded into path: %@", localPath );
	_completionBlock( YES, localPath );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
	DEBUG_LOG( @"There was an error loading the file - %@", [error localizedDescription] );
	_completionBlock( NO, nil );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
	// Set contents
	_contents[ metadata.path ] = metadata.contents;

	// Call completion block
	_completionBlock( YES, metadata.contents );
	_isBusy = NO;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
	DEBUG_LOG( @"Error loading metadata: %@", [error localizedDescription] );
	_completionBlock( NO, nil );
	_isBusy = NO;
}

@end
