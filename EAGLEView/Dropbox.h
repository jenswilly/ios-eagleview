//
//  Dropbox.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

typedef void(^foldercompletionBlock_t)(BOOL success, NSArray *contents);
typedef void(^fileCompletionBlock_t)(BOOL success, NSString *filePath);


@interface Dropbox : NSObject <DBRestClientDelegate>

+ (Dropbox*)sharedInstance;
- (BOOL)isBusy;
- (BOOL)loadContentsForFolder:(NSString*)path completion:(foldercompletionBlock_t)completion;
- (BOOL)loadFileAtPath:(NSString*)path completion:(fileCompletionBlock_t)completion;
- (BOOL)hasCachedContentsForFolder:(NSString*)path;

@end
