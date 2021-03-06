//
//  EAGLEFileView.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLEFile.h"

@interface EAGLEFileView : UIView

@property (strong, nonatomic) EAGLEFile *file;
@property (nonatomic, assign) CGFloat zoomFactor;
@property (assign) CGFloat minZoomFactor;
@property (assign) CGFloat maxZoomFactor;
@property (readonly) CGSize calculatedContentSize;	// Returns the value from the last time instrinsicContentSize was called.
@property (assign, nonatomic) CGFloat relativeZoomFactor;	// Relative zoom between 0 and 1
@property (readonly) CGPoint origin;
@property (strong, nonatomic) NSArray *highlightedElements;	// Array of EAGLEElement objects

- (void)zoomToFitSize:(CGSize)fitSize animated:(BOOL)animated;
- (id)objectsAtPoint:(CGPoint)point;
- (CGPoint)eagleCoordinateToViewCoordinate:(CGPoint)eagleCoordinate;
- (CGPoint)viewCoordinateToEagleCoordinate:(CGPoint)viewCoordinate;
- (NSUInteger)highlightPartWithName:(NSString *)name;
//- (void)highlightElements:(NSArray*)elements;	// Array of EAGLEElement objects

@end
