//
//  ImageDownloadQueue.m
//  Schneider
//
//  Created by Jens Willy Johannsen on 18/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPImageDownloadQueue.h"
#import "GPImageDownloadOperation.h"
#import "GPFileCache.h"

@implementation GPImageDownloadQueue
{
	NSMutableArray *_downloadStack;
	NSMutableDictionary *_downloadDictionary;
	NSOperationQueue *_opqueue;
}

+ (GPImageDownloadQueue*)sharedInstance
{
    static dispatch_once_t once;
    static GPImageDownloadQueue *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
	if( (self = [super init]) )
	{
		// Initialize operation queue
		_opqueue = [[NSOperationQueue alloc] init];
		_opqueue.maxConcurrentOperationCount = 2;

		// Initialize stack
		_downloadStack = [[NSMutableArray alloc] init];
		_downloadDictionary = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (void)addDownloadOperationForURL:(NSURL*)url forAsyncImageView:(GPAsyncImageView*)asyncImageView placeholderImage:(UIImage*)placeholderImage
{
	// Return immediately if no URL
	if( !url || [[url absoluteString] isEqualToString:@""] )
    {
		// No URL: set placeholder image if specified
		if( placeholderImage != nil )
			asyncImageView.image = placeholderImage;

		return;
    }

	// Do we already have an operation for that image view?
	NSString *key = [self identifierForImageView:asyncImageView];
	GPImageDownloadOperation *operation = [_downloadDictionary objectForKey:key];
	if( operation )
	{
		// Yes, we do: cancel it (we don't need to remove it from the dictionary since it will be replace when we add it again or remove it from queue since it is marked as cancelled)
//		DEBUG_LOG( @"Cancelling obsolete download operation for key '%@', url: %@", key, [[operation url] pathComponents][6] );	// pathComponents[6] is the item ID
		[operation cancel];
	}

	// Do we already have a cached image for that url?
	// Does it exist in the file cache?
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [url path], [url query]];
	NSURL *cacheURL = [[GPFileCache sharedInstance] URLForCachedImageAtPath:cachePath];
	if( cacheURL )
	{
		// Yes: set it immediately
		asyncImageView.image = [[GPFileCache sharedInstance] cachedImageAtPath:cachePath];

		return;
	}

	// Valid URL and no cached image. Set the placeholder image now.
	if( placeholderImage )
		asyncImageView.image = placeholderImage;
	
	// Create a new operation
	GPImageDownloadOperation *op = [[GPImageDownloadOperation alloc] initWithURL:url forAsyncImageView:asyncImageView];
//	DEBUG_LOG( @"Adding download operation for key %@: %@", key, [[op url] pathComponents][6] );	// pathComponents[6] is the item ID
	
	// Add the operation to the queue and add it to the dictionary
	[_opqueue addOperation:op];
	[_downloadDictionary setObject:op forKey:key];
}

- (void)cancelDownloadOperationForAsyncImageView:(GPAsyncImageView*)asyncImageView
{
	// Attempt to find corresponding operation in dictionary
	NSString *key = [self identifierForImageView:asyncImageView];
	GPImageDownloadOperation *operation = [_downloadDictionary objectForKey:key];

	// Cancel it (if nil, nothing will happen)
	[operation cancel];
}

- (NSString*)identifierForImageView:(GPAsyncImageView*)asyncImageView
{
	return [NSString stringWithFormat:@"GPASIV-%p", asyncImageView];
}

@end
