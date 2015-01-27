//
//  ImageDownloadOperation.m
//  Schneider
//
//  Created by Jens Willy Johannsen on 18/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPImageDownloadOperation.h"
#import "GPAsyncImageView.h"
#import "AppDelegate.h"
#import "GPFileCache.h"
#import "GPNetworkIndicator.h"

#define MAX_AUTHENTICATION_CHALLENGE_FAILURES 2

@implementation GPImageDownloadOperation
{
	BOOL _isFinished;
	BOOL _isExecuting;
	NSMutableData *_data;
	NSURLConnection *_conn;
	int _authenticationChallengeFailureCount;
	NSURL *_url;
	GPAsyncImageView *_asyncImageView;
	NSError *_error;
}

- (id)initWithURL:(NSURL*)url forAsyncImageView:(GPAsyncImageView*)asyncImageView
{
	if( (self = [super init]) )
	{
		_isFinished = NO;
		_isExecuting = NO;
		
		// Remember url and image view
		_url = url;
		_asyncImageView = asyncImageView;
	}

	return self;
}

- (NSURL *)url
{
	return _url;
}

- (BOOL)isConcurrent
{
	// Yes, we run concurrently on the main thread
	return YES;
}

- (BOOL)isFinished
{
	return _isFinished;
}

- (BOOL)isExecuting
{
	return _isExecuting;
}

- (void)done
{
	// We're done: clear download connection and hide network indicator
	[_conn cancel],
	_conn = nil;
	[GPNetworkIndicator hide];

    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
	
    [self willChangeValueForKey:@"isFinished"];
    _isFinished  = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start
{
//	DEBUG_LOG( @"Starting operation for %@", [_url absoluteString] );
	
    // Set state to isExecurint (KVO compliantly)
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

	// Ensure that the operation should execute
    if( _isFinished || [self isCancelled] )
	{
		[self done];
        return;
	}

	// Start the download operation
	_data = [[NSMutableData alloc] init];
	_authenticationChallengeFailureCount = 0;

	// Instantiate connection and start downloading
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
	request.HTTPMethod = @"GET";
	request.timeoutInterval = 20;
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;

	// Instantiate connection and schedule it on the main thread. We need to do this because NSOperationQueues normally run on a separata background thread.
	_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	dispatch_async(dispatch_get_main_queue(), ^{
		NSRunLoop *loop = [NSRunLoop currentRunLoop];
		[_conn scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
		[_conn start];
	});

	[GPNetworkIndicator show];
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// Check for something other than 200
	if( [response isKindOfClass:[NSHTTPURLResponse class]] )
		if( [(NSHTTPURLResponse*)response statusCode] != 200 && [(NSHTTPURLResponse*)response statusCode] != 201 )
		{
			// Error
			_error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:[(NSHTTPURLResponse*)response statusCode] userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Got HTTP code %d", (int)[(NSHTTPURLResponse*)response statusCode]] forKey:NSLocalizedDescriptionKey]];

			// But continue so we can get the error text as well
		}

	// Flush data
    [_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// Have we been cancelled?
	if( [self isCancelled] )
	{
		// Yes: cancel connection and stop operation
		[_conn cancel];
		[self done];
	}
	else
		// Append received data
		[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if( _error != nil )
	{
		// We received an HTTP error code: log it
		NSLog( @"Error downloading from %@: %@", [_url absoluteString], [_error localizedDescription] );
	}
	else
	{
		// No errors: convert to image. Do all this stuff on a background thread. The NSURLConnection delegate callbacks are received on the main thread (since we explicitly scheduled it on the main thread) and we don't want to block.

		// First, make sure we haven't been cancelled
		if( ![self isCancelled] )
		{
			dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

				// Convert to image
				UIImage *image = [UIImage imageWithData:_data];

				// if image was created
				if( image )
				{
					// Set scale if necessary
					if( image.scale != _asyncImageView.scale )
					{
						UIImage *tmpImage = [UIImage imageWithCGImage:image.CGImage scale:_asyncImageView.scale orientation:image.imageOrientation];
						image = tmpImage;
					}

					// Add rounded corners (even though they may already be rounded)
					//image = [image imageByRoundingCorners:18.0f];

					// Set the image on main thread
					dispatch_async(dispatch_get_main_queue(), ^{
						_asyncImageView.alpha = 0;
						_asyncImageView.image = image;
						[UIView animateWithDuration:0.2 animations:^{
							_asyncImageView.alpha = 1;
						}];
					});

					// Cache it
					NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [_url path], [_url query]];
					[[GPFileCache sharedInstance] cacheImage:image withPath:cachePath quality:GPFileCacheImageQualityJPG50];
				}
#if DEBUG
				else
					NSLog( @"bad image data: %@", [_url absoluteString] );
#endif
			});
		}
#if DEBUG
		else
			NSLog( @"Operation is cancelled in didFinishLoading." );
#endif
	}

	// We're done with the operation
	[self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err
{
	// Error occurred: log it
	NSLog( @"Error downloading from %@: %@", [_url absoluteString], [_error localizedDescription] );

	// We're done
	[self done];
}

@end
