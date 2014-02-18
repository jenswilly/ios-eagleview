//
//  ComponentSearchViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/02/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EAGLEFileView;

@interface ComponentSearchViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) EAGLEFileView *fileView;

@end
