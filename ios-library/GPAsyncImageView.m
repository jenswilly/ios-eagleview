//
//  GPAsyncImageView.m
//
//  Created by Jens Willy Johannsen on 16-05-11.
//  Copyright 2011 Greener Pastures. All rights reserved.
//

#import "GPAsyncImageView.h"
#import "GPFileCache.h"
#import "AppDelegate.h"
#import "GPAsyncURLConnection.h"
#import "GPNetworkIndicator.h"

// Static counter for spinner indicator
static int spinnerCounter = 0;

@implementation GPAsyncImageView
{
	NSURLCredential *_credentials;
}

@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
	if( (self=[super initWithFrame:frame]) )
		[self privateInit];
		
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( (self=[super initWithCoder:aDecoder]) )
		[self privateInit];
	
	return self;
}

- (void)privateInit
{
	scale = 1;	// Default scale
}

- (void)setImage:(UIImage*)image
{
	// Set spinner hidden if present
	if( loadingSpinner )
		loadingSpinner.hidden = YES;
	
	// Set imageUrl to nil so the image will not be set if an ongoing operations completes at a later time
	urlString = nil;
	
	// And set the image
	[super setImage:image];
}

- (void)loadImageFromURL:(NSURL*)url
{
	// Load without completion block
	[self loadImageFromURL:url completion:nil placeHolderImage:nil];	  
}

- (void)loadImageFromURL:(NSURL*)url basicAuthenticationCredentials:(NSURLCredential*)credentials completion:(void(^)())completeBlock placeHolderImage:(UIImage*)placeHolderImage
{
	// Remember credentials
	_credentials = credentials;

	// Load image
	[self loadImageFromURL:url completion:completeBlock placeHolderImage:placeHolderImage];
}

- (void)loadImageFromURL:(NSURL*)url completion:(void (^)())completeBlock placeHolderImage:(UIImage*)placeHolderImage
{	
	// Return immediately if no URL
	if( !url || [[url absoluteString] isEqualToString:@""] )
    {
        if( placeHolderImage != nil )
            self.image = placeHolderImage;
        
        // If there is a completion block, call it
		if( completeBlock )
			completeBlock();
		return;
    }
	
	// Does it exist in the file cache?
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [url path], [url query]];
	NSURL *cacheURL = [[GPFileCache sharedInstance] URLForCachedImageAtPath:cachePath];
	if( cacheURL )
	{
		// Yes: set it immediately
		self.image = [[GPFileCache sharedInstance] cachedImageAtPath:cachePath scale:self.scale];
		
		// If there is a completion block, call it
		if( completeBlock )
			completeBlock();
		return;
	}
	
	// We should load: start by setting the placeholder image is one is specified. Schedule it on the main thread
	if( placeHolderImage != nil )
		self.image = placeHolderImage;

	// Remember urlString so we can compare when the image has been loaded.
	// This is necessary because we might start two or more loading operations before the first one completes and we only want to use the image for the most recent one
	urlString = [url absoluteString];
	
	// Load asynchronously with current credentials
	__weak GPAsyncImageView *weakSelf = self;
	__block NSURL *blockUrl = url;
	[self showSpinner];
	[GPNetworkIndicator show];
	[GPAsyncURLConnection AsyncURLConnectionWithUrl:url userInfo:nil completeBlock:^(NSData *data, id userInfo) {

		// Load complete. First, hide spinner and activity indicator
		[weakSelf hideSpinner];
		[GPNetworkIndicator hide];

		// Convert to image on background thread
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
		dispatch_async( queue, ^{

			// Convert to image
			UIImage *image = [UIImage imageWithData:data];

			// if image was created
			if( image )
			{
				if( image.scale != weakSelf.scale )
				{
					UIImage *tmpImage = [UIImage imageWithCGImage:image.CGImage scale:weakSelf.scale orientation:image.imageOrientation];
					image = tmpImage;
				}

				// If the loaded URL does not match the current urlString, we will not set it since this image is no longer relevant.
				// Also, we won't remove the spinner because it has already been removed by another load operation and will be removed when that operation completes
				if( [urlString isEqualToString:[blockUrl absoluteString]] )
				{
					// Set the image and remove the spinner on main thread
					dispatch_async(dispatch_get_main_queue(), ^{
						weakSelf.image = image;

						// If there is a completion block, call it
						if( completeBlock )
							completeBlock();
					});
				}

				// Cache it
				NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [blockUrl path], [blockUrl query]];
				[[GPFileCache sharedInstance] cacheImage:image withPath:cachePath quality:GPFileCacheImageQualityPNG];
			}
#if DEBUG
			else
				NSLog( @"bad image data: %@", [blockUrl absoluteString] );
#endif
		});
		
	} errorBlock:^(NSError *error) {

		// Error while loading image: hide spinner and do nothing further
		[weakSelf hideSpinner];
		[GPNetworkIndicator hide];
	}];


	/*
	// Start loading in the background (synchronously)
	// Make sure we have block-safe variables for the operation because the image view might disappear before we get to start the block operation
	__block GPAsyncImageView *blockSelf = self;
	__block NSURL *blockUrl = url;

	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
	dispatch_async( queue, ^{
		
		// Show spinner
		[blockSelf showSpinner];
		
		// Make request and start loading
		NSURLRequest *request = [NSURLRequest requestWithURL:blockUrl];
		[APP showNetworkActivityIndicator];
		NSData *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		[APP hideNetworkActivityIndicator];

		// Convert to image
		UIImage *image = [UIImage imageWithData:imgData];
		
		// if image was created
		if( image )
		{
			if( image.scale != blockSelf.scale )
			{
				UIImage *tmpImage = [UIImage imageWithCGImage:image.CGImage scale:blockSelf.scale orientation:image.imageOrientation];
				image = tmpImage;
			}
		
			// If the loaded URL does not match the current urlString, we will not set it since this image is no longer relevant.
			// Also, we won't remove the spinner because it has already been removed by another load operation and will be removed when that operation completes
			if( [urlString isEqualToString:[blockUrl absoluteString]] )
			{
				// Set the image and remove the spinner on main thread
				dispatch_async(dispatch_get_main_queue(), ^{
					blockSelf.image = image;
				
					// If there is a completion block, call it
					if( completeBlock )
						completeBlock();
				});
			}
		
			// Cache it
			[[GPFileCache sharedInstance] cacheImage:image withPath:[blockUrl path] quality:GPFileCacheImageQualityJPG50];
		}
		else
			DEBUG_LOG( @"bad image data: %@", [blockUrl absoluteString] );
		
		// Hide spinner
		[blockSelf hideSpinner];		
	});
	 */
}

#pragma mark - Utility methods

// Shows spinner indicator
- (void)showSpinner
{
	if( spinnerCounter <= 0 )
	{
		@synchronized( self )
		{
			spinnerCounter = 0;
			spinnerCounter++;
		}
		loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[loadingSpinner setCenter:CGPointMake( roundf( self.bounds.size.width/2 ), roundf( self.bounds.size.height/2 ))];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubview:loadingSpinner];
			[loadingSpinner startAnimating];
		});
	}
	else
	{
		// Show spinner if it is hidden
		if( loadingSpinner.hidden )
			loadingSpinner.hidden = NO;
		
		@synchronized( self )
		{
			spinnerCounter++;
		}
	}
}

// Hides spinner indicator
- (void)hideSpinner
{
	@synchronized( self )
	{
		spinnerCounter--;
		if( spinnerCounter < 0 )
			spinnerCounter = 0;
	}
	
	// Hide spinner if done accessing
	if( spinnerCounter == 0 )
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[loadingSpinner stopAnimating];
			[loadingSpinner removeFromSuperview];
			loadingSpinner = nil;
		});
	}
}

@end
