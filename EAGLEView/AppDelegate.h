//
//  AppDelegate.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

#define DROPBOX_APP_KEY @"j6eochke254gdsj"
#define DROPBOX_APP_SECRET @"pgvi4d7y3gt2lx0"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) ViewController *viewController;

@end
