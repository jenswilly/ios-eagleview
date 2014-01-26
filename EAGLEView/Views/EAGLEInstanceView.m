//
//  EAGLEInstanceView.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEInstanceView.h"

@implementation EAGLEInstanceView

- (void)setInstance:(EAGLEInstance *)instance
{
	_instance = instance;

	// We need to redraw
	[self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Flip coordinate system to match EAGLE's
	CGContextTranslateCTM( context, 0, self.bounds.size.height );
	CGContextScaleCTM( context, 1, -1 );

	// Move center to middle of view
	CGContextTranslateCTM( context, self.bounds.size.width/2, self.bounds.size.height/2 );

	// Set zoom level to fill entire view
	CGFloat width = [_instance maxX] - [_instance minX];
	CGFloat height = [_instance maxY] - [_instance minY];
	CGFloat widthFactor = self.bounds.size.width / width;
	CGFloat heightFactor = self.bounds.size.height / height;
	CGFloat zoom = (widthFactor < heightFactor ? widthFactor : heightFactor );
	CGContextScaleCTM( context, zoom, zoom );

	// Offset by the instance's coordinate
	CGContextTranslateCTM( context, -self.instance.point.x, -self.instance.point.y );	// Translate so origin point is 0,0

	[self.instance drawInContext:context];
}

@end
