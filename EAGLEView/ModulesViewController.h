//
//  ModulesViewController.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 19/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EAGLESchematic;

@interface ModulesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong) EAGLESchematic *schematic;

@end
