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

- (void)documentChooserPickedDropboxFile:(DBMetadata *)metadata lastPath:(NSString*)lastPath;

@end

@interface DocumentChooserViewController : UIViewController

@property (weak) id<DocumentChooserDelegate> delegate;
@property (strong, nonatomic) DBMetadata *item;	// The Dropbox item to show contents for
@property (strong, nonatomic) NSString *path;	// Dropbox path to show contents for

- (void)setInitialPath:(NSString*)path;	// See comments in .m file for usage

@end
