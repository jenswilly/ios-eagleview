//
//  LayersViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EAGLEFile;
@class EAGLEFileView;

@interface LayersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) EAGLEFile *eagleFile;
@property (weak) EAGLEFileView *fileView;

@end
