//
//  GPAsyncImageView.h
//
//  Created by Jens Willy Johannsen on 16-05-11.
//  Copyright 2011 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Scaling.h"


@interface GPAsyncImageView : UIImageView
{
	UIActivityIndicatorView *loadingSpinner;
	__block NSString *urlString;
}

@property (nonatomic, assign) CGFloat scale;

- (void)privateInit;
- (void)loadImageFromURL:(NSURL*)url;
- (void)loadImageFromURL:(NSURL*)url completion:(void(^)())completeBlock placeHolderImage:(UIImage*)placeHolderImage;
- (void)loadImageFromURL:(NSURL*)url basicAuthenticationCredentials:(NSURLCredential*)credentials completion:(void(^)())completeBlock placeHolderImage:(UIImage*)placeHolderImage;

@end
