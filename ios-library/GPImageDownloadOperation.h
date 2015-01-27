//
//  ImageDownloadOperation.h
//  Schneider
//
//  Created by Jens Willy Johannsen on 18/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPAsyncImageView;

@interface GPImageDownloadOperation : NSOperation <NSURLConnectionDelegate>

- (id)initWithURL:(NSURL*)url forAsyncImageView:(GPAsyncImageView*)asyncImageView;
- (NSURL*)url;

@end
