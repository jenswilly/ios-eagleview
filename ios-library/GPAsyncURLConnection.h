//
//  AsyncURLConnection.h
//
//  Created by Jens Willy Johannsen on 04-11-11.
//  Copyright (c) 2011 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	GPAsyncURLConnectionErrorCode_NoError = 0,
	GPAsyncURLConnectionErrorCode_AuthenticationChallengeFailureCountExceeded = 101
	
} GPAsyncURLConnectionErrorCode;

typedef void (^successBlock_t)(NSData *data, id userInfo);
typedef void (^errorBlock_t)(NSError *error);

extern NSString* const kHTTPErrorMessage;

@interface GPAsyncURLConnection : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *data_;
    successBlock_t completeBlock_;
    errorBlock_t errorBlock_;
	NSError *error;
	NSURLConnection *conn;
	NSURLCredential *_credentials;
	id _userInfo;	// User info which will be passed back to the caller when load is complete
	NSInteger _authenticationChallengeFailureCount;
}

+ (id)AsyncURLConnectionWithRequest:(NSURLRequest*)request userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionWithUrl:(NSURL*)requestUrl basicAuthenticationCredentials:(NSURLCredential*)credentials userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionForJsonPostWithUrl:(NSURL*)requestUrl postData:(id)postData userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionForPostWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionForPostWithHTTPBody:(NSData*)HTTPBody url:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionForGetWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
+ (id)AsyncURLConnectionOnBackgroundThreadWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;

- (id)initWithRequest:(NSURLRequest*)request userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initWithUrl:(NSURL*)requestUrl basicAuthenticationCredentials:(NSURLCredential*)credentials userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initPostConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initPostConnectionWithHTTPBody:(NSData*)HTTPBody url:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initGetConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (id)initJSONPostConnectionWithUrl:(NSURL*)requestUrl postData:(id)postData userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
- (void)cancel;

@end

/*
@interface NSURLRequest (DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end
*/