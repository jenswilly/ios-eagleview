//
//  GPFileCache.m
//  FDB
//
//  Created by Jens Willy Johannsen on 11-05-11.
//  Copyright 2011 Greener Pastures. All rights reserved.
//

#import "GPFileCache.h"

// Operation queue size
static const int kGPFileCacheOpqueueSize = 4;

// Singleton object
static GPFileCache *sharedInstance = nil;

@implementation GPFileCache
@synthesize quality=_quality;

+ (GPFileCache*)sharedInstance
{
	@synchronized( self )
	{
		if( sharedInstance == nil )
			sharedInstance = [[self alloc] init];
	}
	
	return sharedInstance;
}

- (id)init
{
	if( (self=[super init] ))
	{
		// Quality defaults to PNG
		_quality = GPFileCacheImageQualityPNG;
		
		// Get documents path
        _cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"cache/"];
#if DEBUG
		NSLog( @"Cache location: %@", _cachePath );
#endif
		
		// Make sure the cache directory exists
		BOOL isDirectory = NO;
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDirectory];
		
		// Does it exist (and is it a directory)
		if( !(exists && isDirectory) )
		{
			// No: create it now
			[[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		_memoryCache = [[NSMutableDictionary alloc] initWithCapacity:100];
	}
	
	return self;

}

- (void)purgeCacheWithTTL:(NSTimeInterval)timeInterval
{
	// Iterate files in cache folder
	NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cachePath error:nil];
	for( NSString *filePath in cacheContents )
	{
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[_cachePath stringByAppendingPathComponent:filePath] error:nil];
		
		// Get modification data
		NSDate *modDate = [attrs fileModificationDate];
		
		// Is it too old?
		NSTimeInterval age = fabs( [modDate timeIntervalSinceNow] );
		if( age > timeInterval )
		{
			// Too old: delete it
			[[NSFileManager defaultManager] removeItemAtPath:[_cachePath stringByAppendingPathComponent:filePath] error:nil];
		}
	}
}

- (NSUInteger)cacheFolderSize
{
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_cachePath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSUInteger fileSize = 0;
	
    while( (fileName = [filesEnumerator nextObject]) )
	{
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[_cachePath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
	
    return fileSize;
}

- (void)loadImageAsynchronouslyAtURL:(NSURL*)url delegate:(id)delegate
{
	// Create opqueue if it doesn't exist
	if( !_opqueue )
	{
		_opqueue = [[NSOperationQueue alloc] init];
		[_opqueue setMaxConcurrentOperationCount:kGPFileCacheOpqueueSize];
	}
	
	__block GPFileCache *blockSelf = self;	
	__block GPFileCacheImageQuality blockQuality = _quality;
	__block NSMutableDictionary *blockMemoryCache = _memoryCache;
	[_opqueue addOperationWithBlock:
	^{
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
		
		// If nil, exit immediately
		if( image == nil && [delegate respondsToSelector:@selector(imageLoaded:)] )
		{
			[(NSObject*)delegate performSelectorOnMainThread:@selector(imageLoaded:) withObject:nil waitUntilDone:NO];
			return;
		}
		
		// Callback
		if( [delegate respondsToSelector:@selector(imageLoaded:)] )
			[(NSObject*)delegate performSelectorOnMainThread:@selector(imageLoaded:) withObject:image waitUntilDone:NO];
		
		// Cache it
		[blockSelf cacheImage:image withPath:[url path] quality:blockQuality];
		@synchronized( blockSelf )
		{
			[blockMemoryCache setObject:image forKey:[url path]];
		}
	}];
}

- (void)loadImageAsynchronouslyAtURL:(NSURL*)url delegate:(id)delegate context:(id)context
{
	// Create opqueue if it doesn't exist
	if( !_opqueue )
	{
		_opqueue = [[NSOperationQueue alloc] init];
		[_opqueue setMaxConcurrentOperationCount:kGPFileCacheOpqueueSize];
	}
	
	__block GPFileCache *blockSelf = self;
	__block GPFileCacheImageQuality blockQuality = _quality;
	[_opqueue addOperationWithBlock:
	 ^{
		 UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
		 
		 // Callback
		 if( [delegate respondsToSelector:@selector(imageLoaded:context:)] )
			 [delegate imageLoaded:image context:context];
		 
		 // Cache it
		 [blockSelf cacheImage:image withPath:[url path] quality:blockQuality];
		 [blockSelf cacheImageInMemoryCache:image forPath:[url path]];
	 }];
}

- (NSURL*)URLForCachedImageAtPath:(NSString*)path
{
	// format path
	if( [path hasPrefix:@"/"] )	// Does it start with a /?
		path = [path substringFromIndex:1];	// If yes, remove it to ensure cache key consistency
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"^"];
	// Create full path
	NSString *fullPath = [_cachePath stringByAppendingPathComponent:path];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
	{
		// Get URL
		return [NSURL fileURLWithPath:fullPath];
	}
	else
		return nil;
}

- (UIImage*)cachedImageAtPath:(NSString*)path
{
	return [self cachedImageAtPath:path scale:1];
}

- (UIImage*)cachedImageAtPath:(NSString*)path scale:(CGFloat)scale
{
	// format path
	if( [path hasPrefix:@"/"] )	// Does it start with a /?
		path = [path substringFromIndex:1];	// If yes, remove it to ensure cache key consistency
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"^"];

	// Is it cached in memory?
	@synchronized( self )
	{
		if( [_memoryCache objectForKey:path] )
			// Yes: return it
			return [_memoryCache objectForKey:path];
	}
	
	// Create full path
	NSString *fullPath = [_cachePath stringByAppendingPathComponent:path];

	if( [[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
	{
		// Get image
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath] scale:scale];
		[self cacheImageInMemoryCache:image forPath:path];
		return image;
	}
	else
		return nil;
}

- (void)cacheImageInMemoryCache:(UIImage*)image forPath:(NSString*)path
{
	@synchronized( self )
	{
		if ( image )
			[_memoryCache setObject:image forKey:path];
	}
}

- (UIImage*)memoryCachedImageAtPath:(NSString*)path
{
	// Return it if it is in the memory cache
	@synchronized( self )
	{
		return [_memoryCache objectForKey:path];
	}
}

- (void)flushMemoryCache
{
	// Clear the memory cache
	@synchronized( self )
	{
		[_memoryCache removeAllObjects];
	}
}

- (void)cacheImage:(UIImage*)image withPath:(NSString*)path quality:(GPFileCacheImageQuality)quality
{
	// format path
	if( [path hasPrefix:@"/"] )	// Does it start with a /?
		path = [path substringFromIndex:1];	// If yes, remove it to ensure cache key consistency
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"^"];

	// Create full path
	NSString *fullPath = [_cachePath stringByAppendingPathComponent:path];
	
	// Convert to specified format
	NSData *imageData;
	switch( quality )
	{
		case GPFileCacheImageQualityPNG:
			imageData = UIImagePNGRepresentation( image );
			break;
			
		case GPFileCacheImageQualityJPG80:
			imageData = UIImageJPEGRepresentation( image, 0.8 );
			break;
			
		case GPFileCacheImageQualityJPG50:
			imageData = UIImageJPEGRepresentation( image, 0.5 );
			break;
	}
	
	// Does the target folder exist (and is it a directory)
	NSString *folderPath = [[[fullPath pathComponents] subarrayWithRange:NSMakeRange(0, [[fullPath pathComponents] count]-1)] componentsJoinedByString:@"/"];
	
	BOOL isDirectory = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDirectory];
	if( !(exists && isDirectory) )
	{
		// No: create it now
		[[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}

	
	// Save file
	[imageData writeToFile:fullPath atomically:YES];
//	DEBUG_LOGF( @"Image cached: %@", path );
}

// Save array of venues to disc to file
- (void)saveArrayToFileCache:(NSArray*)array fileName:(NSString*)fileName
{
	// Get path to file
	NSString* fullFileName = [_cachePath stringByAppendingPathComponent:fileName];
	
	// Save the array
	[NSKeyedArchiver archiveRootObject:array toFile:fullFileName];
}

- (NSArray*)loadArrayFromFileCache:(NSString*)fileName
{
	// Get path to file
	NSString* fullFileName = [_cachePath stringByAppendingPathComponent:fileName];

	// Load the array
	NSArray *arrayFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:fullFileName];
	
	return arrayFromDisk;
}

#pragma mark - Generic NSData caching methods

- (NSURL*)cacheData:(NSData*)data withPath:(NSString*)path
{
	// Construct full path
	NSString* fullPath = [_cachePath stringByAppendingPathComponent:path];

	// Does the directory exist?
	NSString *folderPath = [fullPath stringByDeletingLastPathComponent];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:folderPath] )
		// Folder doesn't exist: create it
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];

	// Save data
	[data writeToFile:fullPath atomically:YES];

	// Return url to file
	return [NSURL fileURLWithPath:fullPath];
}

- (NSData*)cachedDataAtPath:(NSString*)path
{
	// Construct full path
	NSString* fullPath = [_cachePath stringByAppendingPathComponent:path];

	// Load data
	NSData *data = [NSData dataWithContentsOfFile:fullPath];
	return data;	// Might be nil if file didn't exist
}

- (NSURL*)URLForCachedDataAtPath:(NSString*)path
{
	NSString* fullPath = [_cachePath stringByAppendingPathComponent:path];

	// Does the file exist?
    if( ![[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
		// No: return nil
		return nil;
	else
		// Yes: return URL
		return [NSURL fileURLWithPath:fullPath];
}


@end
