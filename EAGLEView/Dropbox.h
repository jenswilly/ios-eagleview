//
//  Dropbox.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

// Extern definition of the Dropbox folder name (in case it is needed in some other file)
extern NSString* const kDropboxFolderName;

typedef void(^foldercompletionBlock_t)(BOOL success, NSArray *contents, DBMetadata *metadata);
typedef void(^fileCompletionBlock_t)(BOOL success, NSString *filePath, DBMetadata *metadata);


@interface Dropbox : NSObject <DBRestClientDelegate>

+ (Dropbox*)sharedInstance;
- (BOOL)isBusy;
- (BOOL)loadContentsForFolder:(NSString*)path completion:(foldercompletionBlock_t)completion;
- (BOOL)loadFileAtPath:(NSString*)path completion:(fileCompletionBlock_t)completion;
- (BOOL)hasCachedContentsForFolder:(NSString*)path;

/**
 Re-initialize REST client and cache.
 */
- (void)reset;

@end
