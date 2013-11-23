//
//  EAGLESchematicView.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLESchematic.h"

@interface EAGLESchematicView : UIView

@property (strong) EAGLESchematic *schematic;
@property (assign) CGFloat zoomFactor;

@end
