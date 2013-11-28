//
//  EAGLESchematicView.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLESchematicView.h"
#import "EAGLESymbol.h"
#import "EAGLELibrary.h"
#import "EAGLEDrawableObject.h"
#import "EAGLEInstance.h"
#import "EAGLENet.h"

@implementation EAGLESchematicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		_minZoomFactor = 1;
		_maxZoomFactor = 100;
		_zoomFactor = 15;	// Default zoom factor
    }

    return self;
}

- (void)awakeFromNib
{
	_minZoomFactor = 1;
	_maxZoomFactor = 100;
	_zoomFactor = 15;
}

- (void)setRelativeZoomFactor:(CGFloat)relativeFactor
{
	CGFloat span = _maxZoomFactor - _minZoomFactor;
	self.zoomFactor = _minZoomFactor + relativeFactor * span;

	// Invalidate size and drawing
	[self invalidateIntrinsicContentSize];
	[self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
	CGFloat maxX = -MAXFLOAT;
	CGFloat maxY = -MAXFLOAT;

	for( id<EAGLEDrawable> drawable in self.schematic.instances )
	{
		maxX = MAX( maxX, [drawable maxX] );
		maxY = MAX( maxY, [drawable maxY] );
	}

	for( id<EAGLEDrawable> drawable in self.schematic.nets )
	{
		maxX = MAX( maxX, [drawable maxX] );
		maxY = MAX( maxY, [drawable maxY] );
	}

	for( id<EAGLEDrawable> drawable in self.schematic.busses )
	{
		maxX = MAX( maxX, [drawable maxX] );
		maxY = MAX( maxY, [drawable maxY] );
	}

	for( id<EAGLEDrawable> drawable in self.schematic.plainObjects )
	{
		maxX = MAX( maxX, [drawable maxX] );
		maxY = MAX( maxY, [drawable maxY] );
	}

	CGSize contentSize = CGSizeMake( maxX * _zoomFactor, maxY * _zoomFactor );
	return contentSize;
}

- (void)drawRect:(CGRect)rect
{
	// Fix the coordinate system so 0,0 is at bottom-left
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM( context, 0, self.bounds.size.height );
	CGContextScaleCTM( context, 1, -1 );

//	CGContextTranslateCTM( context, 100, 100 );

	// Set zoom level
	CGContextScaleCTM( context, self.zoomFactor, self.zoomFactor );

	/// TEMP: draw all instances, nets, busses and plain objects
	for( id<EAGLEDrawable> drawable in self.schematic.instances )
		[drawable drawInContext:context];
	for( id<EAGLEDrawable> drawable in self.schematic.nets )
		[drawable drawInContext:context];
	for( id<EAGLEDrawable> drawable in self.schematic.busses )
		[drawable drawInContext:context];
	for( id<EAGLEDrawable> drawable in self.schematic.plainObjects )
		[drawable drawInContext:context];
}

@end
