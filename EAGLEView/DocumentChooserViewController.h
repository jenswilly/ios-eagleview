//
//  DocumentChooserViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DBMetadata;

@protocol DocumentChooserDelegate <NSObject>

- (void)documentChooserPickedDropboxFile:(DBMetadata*)metadata;

@end

@interface DocumentChooserViewController : UIViewController

@property (weak) id<DocumentChooserDelegate> delegate;
@property (strong, nonatomic) NSString *path;	// The Dropbox path to show contents for

@end
