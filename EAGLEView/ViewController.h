//
//  ViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentChooserViewController.h"
@class EAGLESchematic;

@interface ViewController : UIViewController <UIScrollViewDelegate, DocumentChooserDelegate>

- (void)openFileFromURL:(NSURL*)fileURL;
- (void)openSchematic:(EAGLESchematic*)schematic;

@end
