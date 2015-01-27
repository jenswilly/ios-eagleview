//
//  UIImage+Scaling.m
//  Fleggaard
//
//  Created by Jens Willy Johannsen on 26-10-10.
//  Copyright 2010 Greener Pastures. All rights reserved.
//

#import "UIImage+Scaling.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation UIImage (Scaling)

-(UIImage *)imageAtRect:(CGRect)rect
{
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage* subImage = [UIImage imageWithCGImage: imageRef];
	CGImageRelease(imageRef);
	
	return subImage;
	
}

- (UIImage*)imageByRoundingCorners:(CGFloat)radius
{
	// Add round corners
	// Begin a new image that will be the new image with the rounded corners
	// (here with the size of an UIImageView)
	UIGraphicsBeginImageContextWithOptions( self.size, NO, self.scale );

	// Add a clip before drawing anything, in the shape of an rounded rect
	[[UIBezierPath bezierPathWithRoundedRect:CGRectMake( 0, 0, self.size.width, self.size.height ) cornerRadius:radius] addClip];

	// Draw your image
	[self drawInRect:CGRectMake( 0, 0, self.size.width, self.size.height )];

	// Get the image, here setting the UIImageView image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

	// Lets forget about that we were drawing
	UIGraphicsEndImageContext();

	return image;
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor > heightFactor) 
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		} else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}

- (UIImage*)imageByAspectFillingSize:(CGSize)targetSize
{
	CGFloat widthFactor = targetSize.width / self.size.width;
	CGFloat heightFactor = targetSize.height / self.size.height;
	
	// Which factor is highest?
	CGFloat scaleFactor = MAX( widthFactor, heightFactor );

	// Scaled size
	CGSize scaledSize = CGSizeMake( self.size.width * scaleFactor, self.size.height * scaleFactor );
	
	// Offset image
	CGPoint offsetPoint = CGPointZero;
	if( heightFactor > widthFactor )
		offsetPoint.x = (targetSize.width - scaledSize.width) / 2;
	else
		offsetPoint.y = (targetSize.height - scaledSize.height) / 2;
	
	UIGraphicsBeginImageContext( targetSize );
	CGRect imageRect = CGRectZero;
	imageRect.origin = offsetPoint;
	imageRect.size = scaledSize;
	
	[self drawInRect:imageRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage;	
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor < heightFactor) 
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor < heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		} else if (widthFactor > heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}

- (UIImage*)imageByScalingByFactor:(CGFloat)scaleFactor
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = width * scaleFactor;
	CGFloat targetHeight = height * scaleFactor;
	CGSize targetSize = CGSizeMake( targetWidth, targetHeight );
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect targetRect = CGRectMake( 0, 0, targetWidth, targetHeight );
	[sourceImage drawInRect:targetRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	return newImage ;
}

- (UIImage*)imageByScalingToSize:(CGSize)targetSize interpolation:(CGInterpolationQuality)interpolationQuality
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;

	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;

	//   CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;

	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

	// this is actually the interesting part:

	UIGraphicsBeginImageContextWithOptions( targetSize, NO, self.scale );
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality( context, interpolationQuality );

	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;

	[sourceImage drawInRect:thumbnailRect];

	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if(newImage == nil) NSLog(@"could not scale image");

	return newImage;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	//   CGSize imageSize = sourceImage.size;
	//   CGFloat width = imageSize.width;
	//   CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	//   CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
	return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.height, self.size.width)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)imageByFlippingHorizontal
{
	// Create the bitmap context
	UIGraphicsBeginImageContext( self.size );
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Now, draw the rotated/scaled image into the context
	CGContextTranslateCTM( bitmap, self.size.width, self.size.height );
	CGContextScaleCTM(bitmap, -1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage );
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

// Scales to specified width
- (UIImage*)imageByScalingProportionallyToWidth: (CGFloat)targetWidth
{
	CGRect targetRect = CGRectMake( 0, 0, targetWidth, self.size.height * targetWidth/self.size.width );
	
	UIGraphicsBeginImageContextWithOptions( targetRect.size, NO, self.scale );
	[self drawInRect:targetRect];
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil)
		NSLog(@"could not scale image");
	
	return newImage ;
}

// Scales to specified height
- (UIImage*)imageByScalingProportionallyToHeight: (CGFloat)targetHeight
{
	CGRect targetRect = CGRectMake( 0, 0, self.size.width * targetHeight/self.size.height, targetHeight );
	
	UIGraphicsBeginImageContext( targetRect.size );
	[self drawInRect:targetRect];
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil)
		NSLog(@"could not scale image");
	
	return newImage ;
}


@end