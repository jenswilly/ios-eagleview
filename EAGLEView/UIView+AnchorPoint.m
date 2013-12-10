//
//  UIView+AnchorPoint.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 10/12/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "UIView+AnchorPoint.h"

@implementation UIView (AnchorPoint)

/**
 * Sets the view's layer's anchor point and moves the location so the view will appear in the same location.
 * Based on code from http://stackoverflow.com/a/5666430/1632704
 */
- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint newPoint = CGPointMake( self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y );
    CGPoint oldPoint = CGPointMake( self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y );

    newPoint = CGPointApplyAffineTransform( newPoint, self.transform );
    oldPoint = CGPointApplyAffineTransform( oldPoint, self.transform );

    CGPoint position = self.layer.position;

    position.x -= oldPoint.x;
    position.x += newPoint.x;

    position.y -= oldPoint.y;
    position.y += newPoint.y;

    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

@end
