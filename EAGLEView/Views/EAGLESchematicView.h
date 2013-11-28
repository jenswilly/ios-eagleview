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
@property (assign) CGFloat minZoomFactor;
@property (assign) CGFloat maxZoomFactor;

- (void)setRelativeZoomFactor:(CGFloat)relativeFactor;	// Sets the zoom factor between min. and max. by specifying a number between 0 and 1.

@end
