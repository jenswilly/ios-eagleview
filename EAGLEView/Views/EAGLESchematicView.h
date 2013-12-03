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
@property (readonly) CGSize calculatedContentSize;	// Returns the value from the last time instrinsicContentSize was called.
@property (assign, nonatomic) CGFloat relativeZoomFactor;	// Relative zoom between 0 and 1
@property (readonly) CGPoint origin;

- (void)zoomToFitSize:(CGSize)fitSize animated:(BOOL)animated;

@end
