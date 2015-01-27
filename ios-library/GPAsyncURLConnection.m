//
//  GPAsyncURLConnection.m
//
//  Created by Jens Willy Johannsen on 04-11-11.
//  Copyright (c) 2011 Greener Pastures. All rights reserved.
//

#import "GPAsyncURLConnection.h"
#import "AppDelegate.h"
#import "GPNetworkIndicator.h"

#define MAX_AUTHENTICATION_CHALLENGE_FAILURES 2

NSString* const kHTTPErrorMessage = @"kHTTPErrorMessage";

@implementation GPAsyncURLConnection

+ (id)AsyncURLConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initWithUrl:requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionWithRequest:(NSURLRequest*)request userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initWithRequest:request userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionForPostWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initPostConnectionWithUrl:requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionForPostWithHTTPBody:(NSData*)HTTPBody url:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initPostConnectionWithHTTPBody:(NSData*)HTTPBody url:(NSURL*)requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionForGetWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initGetConnectionWithUrl:requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionForJsonPostWithUrl:(NSURL*)requestUrl postData:(id)postData userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initJSONPostConnectionWithUrl:requestUrl postData:postData userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionOnBackgroundThreadWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initOnBackgroundThreadWithUrl:requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)AsyncURLConnectionWithUrl:(NSURL*)requestUrl basicAuthenticationCredentials:(NSURLCredential*)credentials userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	return [[GPAsyncURLConnection alloc] initWithUrl:requestUrl basicAuthenticationCredentials:credentials userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock];
}

- (id)initWithRequest:(NSURLRequest*)request userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;
		
		conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
		[conn start];

		[GPNetworkIndicator show];
    }
	
    return self;
}

- (id)initOnBackgroundThreadWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];

        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;

		conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:requestUrl] delegate:self startImmediately:NO];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSRunLoop *loop = [NSRunLoop currentRunLoop];
			[conn scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
			[conn start];
			[loop run]; // make sure that you have a running run-loop.
		});

		[GPNetworkIndicator show];
    }

    return self;
}

- (id)initWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;

        NSURL *url = requestUrl;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        conn = [NSURLConnection connectionWithRequest:request delegate:self];
		[GPNetworkIndicator show];
    }
	
    return self;
}

- (id)initPostConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;
		
        NSURL *url = requestUrl;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		request.HTTPMethod = @"POST";
		request.timeoutInterval = 20;

        conn = [NSURLConnection connectionWithRequest:request delegate:self];
		[GPNetworkIndicator show];
    }
	
    return self;
}

// Adapted to work with POST's to Realdania API SOAP 1.2
- (id)initPostConnectionWithHTTPBody:(NSData*)HTTPBody url:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;
		
        NSURL *url = requestUrl;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		request.HTTPMethod = @"POST";
		request.timeoutInterval = 20;
		
		// Set content type
		NSString *contentType = [NSString stringWithFormat:@"application/soap+xml; charset=utf-8"];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
		
		// Setting the body of the post to the reqeust
		[request setHTTPBody:HTTPBody];
		
        conn = [NSURLConnection connectionWithRequest:request delegate:self];
		[GPNetworkIndicator show];
    }
	
    return self;
}

- (id)initGetConnectionWithUrl:(NSURL*)requestUrl userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;
		
        NSURL *url = requestUrl;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		request.HTTPMethod = @"GET";
		request.timeoutInterval = 20;
		request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
		
        conn = [NSURLConnection connectionWithRequest:request delegate:self];
		[GPNetworkIndicator show];
    }
	
    return self;
}

- (id)initJSONPostConnectionWithUrl:(NSURL*)requestUrl postData:(id)postData userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	if( (self=[super init]) )
	{
        data_ = [[NSMutableData alloc] init];
		
        completeBlock_ = completeBlock;
        errorBlock_ = errorBlock;
		error = nil;
		_authenticationChallengeFailureCount = 0;
		
        NSURL *url = requestUrl;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		request.HTTPMethod = @"POST";
		
		// Convert to json string if it's not already a string
		NSString *jsonString;
		
		if( [postData isKindOfClass:[NSString class]] )
		{
			jsonString = postData;
		}
		else
		{
			NSError *err = nil;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:&err];
			if( error != nil )
			{
				// Error converting to json string
				errorBlock_( err );
				return nil;
			}
			
			jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		}
		
		// Add application/json content type header
		[request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
		
		// Set content length header
		[request addValue:[NSString stringWithFormat:@"%d", (int)[jsonString length]] forHTTPHeaderField:@"Content-Length"];
		
		// Set post body
		[request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
		
        conn = [NSURLConnection connectionWithRequest:request delegate:self];
		[GPNetworkIndicator show];
	}
	
	return self;
}

- (id)initWithUrl:(NSURL*)requestUrl basicAuthenticationCredentials:(NSURLCredential*)credentials userInfo:(id)userInfo completeBlock:(successBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
	// Normal init and rememeber credentials for basic authentication
	if( (self = [self initGetConnectionWithUrl:requestUrl userInfo:userInfo completeBlock:completeBlock errorBlock:errorBlock]) )
	{
		// Remember credentials
		_credentials = credentials;

		// Remember userInfo
		_userInfo = userInfo;
	}

	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// Check for something other than 200
	if( [response isKindOfClass:[NSHTTPURLResponse class]] )

//		DEBUG_LOG(@"statuscode: %d",[(NSHTTPURLResponse*)response statusCode]);
		
		if( [(NSHTTPURLResponse*)response statusCode] != 200 && [(NSHTTPURLResponse*)response statusCode] != 201 )
		{
			// Error
			error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:[(NSHTTPURLResponse*)response statusCode] userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Got HTTP code %d", (int)[(NSHTTPURLResponse*)response statusCode]] forKey:NSLocalizedDescriptionKey]];
			
			// But continue so we can get the error text as well
		}
			
    [data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [data_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[GPNetworkIndicator hide];
	if( error != nil )
	{
		// We received an HTTP error code: append the data to the error object's userInfo
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
		NSString *errorText = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
		[userInfo setObject:errorText forKey:kHTTPErrorMessage];
		
		NSError *err = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:error.code userInfo:userInfo];
		errorBlock_( err );
		conn = nil;
	}
	else
	{
		// No errors
		completeBlock_( data_, _userInfo );
		conn = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err
{
	[GPNetworkIndicator hide];
	errorBlock_(err);
	conn = nil;
}

- (void)cancel
{
	[GPNetworkIndicator hide];
	[conn cancel];
	conn = nil;
	
	// NOTE: no callback blocks when cancelling
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	// We can always accept SSL
	if( [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] )
		return YES;

	// If we have credentials set, we can also authenticate basic authentication
	if( [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] && _credentials )
		return YES;

	// Otherwise, we can't…
	return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	// Counter
	if( _authenticationChallengeFailureCount >= MAX_AUTHENTICATION_CHALLENGE_FAILURES )
	{
		// Login failure
		NSError *err = [NSError errorWithDomain:@"dk.greenerpastures"
										   code:GPAsyncURLConnectionErrorCode_AuthenticationChallengeFailureCountExceeded
									   userInfo:@{ NSLocalizedDescriptionKey: @"Authentication challenge failed" }];

		[GPNetworkIndicator hide];
		[conn cancel],
		conn = nil;
		
		errorBlock_( err );
		return;
	}
	_authenticationChallengeFailureCount++;
	
	// What kind of authentication challange?
    if( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] )
    {
		// SSL: we trust it
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
		// HTTP basic authentication with stored credentials
        [[challenge sender] useCredential:_credentials forAuthenticationChallenge:challenge];
    }
}

@end

/*
@implementation NSURLRequest (DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	DEBUG_LOG( @"Allowing SSL for %@", host );
	return YES; // Should probably return YES only for a specific host
}
@end
*/
