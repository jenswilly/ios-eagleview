//
//  UIImage+Scaling.h
//  Fleggaard
//
//  Created by Jens Willy Johannsen on 26-10-10.
//  Copyright 2010 Greener Pastures. All rights reserved.
//

// Based on work by Hardy Macia, Catamount Software.
// http://www.catamount.com/blog/?p=1015

#import <Foundation/Foundation.h>

@interface UIImage (Scaling)

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage*)imageByScalingToSize:(CGSize)targetSize interpolation:(CGInterpolationQuality)interpolationQuality;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageByScalingByFactor:(CGFloat)scaleFactor;
- (UIImage*)imageByFlippingHorizontal;
- (UIImage*)imageByScalingProportionallyToWidth: (CGFloat)targetWidth;
- (UIImage*)imageByScalingProportionallyToHeight: (CGFloat)targetHeight;
- (UIImage*)imageByAspectFillingSize:(CGSize)targetSize;
- (UIImage*)imageByRoundingCorners:(CGFloat)radius;

@end

CGFloat DegreesToRadians(CGFloat degrees);
CGFloat RadiansToDegrees(CGFloat radians);
