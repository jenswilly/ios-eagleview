//
//  GPFileCache.h
//  FDB
//
//  Created by Jens Willy Johannsen on 11-05-11.
//  Copyright 2011 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPFileCacheAsyncLoadDelegate <NSObject>
@optional
- (void)imageLoaded:(UIImage*)image;
- (void)imageLoaded:(UIImage*)image context:(id)context;

@end

typedef enum
{
	GPFileCacheImageQualityPNG,
	GPFileCacheImageQualityJPG80,
	GPFileCacheImageQualityJPG50
} GPFileCacheImageQuality;

@interface GPFileCache : NSObject
{
    NSString *_cachePath;
	NSOperationQueue *_opqueue;
	GPFileCacheImageQuality _quality;
	NSMutableDictionary *_memoryCache;
}

@property (nonatomic, assign) GPFileCacheImageQuality quality;

+ (GPFileCache*)sharedInstance;

- (void)purgeCacheWithTTL:(NSTimeInterval)timeInterval;
- (NSUInteger)cacheFolderSize;
- (void)cacheImage:(UIImage*)image withPath:(NSString*)path quality:(GPFileCacheImageQuality)quality;
- (UIImage*)cachedImageAtPath:(NSString*)path;
- (UIImage*)cachedImageAtPath:(NSString*)path scale:(CGFloat)scale;
- (void)loadImageAsynchronouslyAtURL:(NSURL*)url delegate:(id)delegate;
- (void)loadImageAsynchronouslyAtURL:(NSURL*)url delegate:(id)delegate context:(id)context;
- (NSURL*)URLForCachedImageAtPath:(NSString*)path;
- (UIImage*)memoryCachedImageAtPath:(NSString*)path;
- (void)flushMemoryCache;
- (void)cacheImageInMemoryCache:(UIImage*)image forPath:(NSString*)path;
- (void)saveArrayToFileCache:(NSArray*)array fileName:(NSString*)fileName;
- (NSArray*)loadArrayFromFileCache:(NSString*)fileName;

- (NSURL*)cacheData:(NSData*)data withPath:(NSString*)path;
- (NSData*)cachedDataAtPath:(NSString*)path;
- (NSURL*)URLForCachedDataAtPath:(NSString*)path;

@end
