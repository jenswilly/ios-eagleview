//
//  ImageDownloadQueue.h
//  Schneider
//
//  Created by Jens Willy Johannsen on 18/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPAsyncImageView.h"

@interface GPImageDownloadQueue : NSObject

+ (GPImageDownloadQueue*)sharedInstance;
- (void)addDownloadOperationForURL:(NSURL*)url forAsyncImageView:(GPAsyncImageView*)asyncImageView placeholderImage:(UIImage*)placeholderImage;

@end
