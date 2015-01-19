//
//  ViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentChooserViewController.h"
#import "EAGLEFileView.h"
@class EAGLEFile;

@interface ViewController : UIViewController <UIScrollViewDelegate, DocumentChooserDelegate>

@property (copy) NSString *lastDropboxPath; // Used to remember which Dropbox path the user was in last
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet EAGLEFileView *fileView;

- (void)openFileFromURL:(NSURL*)fileURL;
- (void)openFile:(EAGLEFile*)file;
- (IBAction)zoomToFitAction:(id)sender;

@end
