//
//  UIImage+Color.m
//  Jabra
//
//  Created by Jens Willy Johannsen on 06/11/12.
//  Copyright (c) 2012 Greener Pastures. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

@end
