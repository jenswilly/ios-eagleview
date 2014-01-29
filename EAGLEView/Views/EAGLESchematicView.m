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
#import "EAGLESchematic.h"
#import "EAGLEBoard.h"
#import "EAGLESignal.h"

static const CGFloat kViewPadding = 5;

@implementation EAGLESchematicView
{
	BOOL _needsCalculateIntrinsicContentSize;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		_minZoomFactor = 1;
		_maxZoomFactor = 100;
		self.zoomFactor = 15;	// Default zoom factor
    }

    return self;
}

- (void)setFile:(EAGLEFile *)file
{
	_file = file;

	// Set background based on type of file
	if( [file isMemberOfClass:[EAGLESchematic class]] )
		self.backgroundColor = [UIColor whiteColor];
	else if( [file isMemberOfClass:[EAGLEBoard class]] )
		self.backgroundColor = [UIColor blackColor];
}

- (void)setZoomFactor:(CGFloat)zoomFactor
{
	_zoomFactor = zoomFactor;
	[self invalidateIntrinsicContentSize];
	[self setNeedsDisplay];
}

- (void)awakeFromNib
{
	_minZoomFactor = 1;
	_maxZoomFactor = 100;
	self.zoomFactor = 15;
}

- (CGFloat)relativeZoomFactor
{
	CGFloat span = _maxZoomFactor - _minZoomFactor;
	CGFloat position = _zoomFactor - _minZoomFactor;

	return position/span;
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
	CGFloat minX = MAXFLOAT;
	CGFloat minY = MAXFLOAT;

	for( id<EAGLEDrawable> drawable in self.file.plainObjects )
	{
		maxX = MAX( maxX, [drawable maxX] );
		maxY = MAX( maxY, [drawable maxY] );
		minX = MIN( minX, [drawable minX] );
		minY = MIN( minY, [drawable minY] );
	}

	// Schematic-only objects
	if( [self.file isMemberOfClass:[EAGLESchematic class]] )
	{
		EAGLESchematic *schematic = (EAGLESchematic*)self.file;
		for( id<EAGLEDrawable> drawable in schematic.instances )
		{
			maxX = MAX( maxX, [drawable maxX] );
			maxY = MAX( maxY, [drawable maxY] );
			minX = MIN( minX, [drawable minX] );
			minY = MIN( minY, [drawable minY] );
		}

		for( id<EAGLEDrawable> drawable in schematic.nets )
		{
			maxX = MAX( maxX, [drawable maxX] );
			maxY = MAX( maxY, [drawable maxY] );
			minX = MIN( minX, [drawable minX] );
			minY = MIN( minY, [drawable minY] );
		}

		for( id<EAGLEDrawable> drawable in schematic.busses )
		{
			maxX = MAX( maxX, [drawable maxX] );
			maxY = MAX( maxY, [drawable maxY] );
			minX = MIN( minX, [drawable minX] );
			minY = MIN( minY, [drawable minY] );
		}
	}

	// Board-only objects
	else if( [self.file isMemberOfClass:[EAGLEBoard class]] )
	{
		EAGLEBoard *board = (EAGLEBoard*)self.file;
		
		for( id<EAGLEDrawable> drawable in board.elements )
		{
			maxX = MAX( maxX, [drawable maxX] );
			maxY = MAX( maxY, [drawable maxY] );
			minX = MIN( minX, [drawable minX] );
			minY = MIN( minY, [drawable minY] );
		}

		for( id<EAGLEDrawable> drawable in board.signals )
		{
			maxX = MAX( maxX, [drawable maxX] );
			maxY = MAX( maxY, [drawable maxY] );
			minX = MIN( minX, [drawable minX] );
			minY = MIN( minY, [drawable minY] );
		}
	}

	// Adjust for negative origin
	maxX -= minX;
	maxY -= minY;

	// Add padding
	maxX += kViewPadding;
	maxY += kViewPadding;

	CGSize contentSize = CGSizeMake( maxX * _zoomFactor, maxY * _zoomFactor );

	// Update properties and return
	_origin = CGPointMake( minX, minY );
	_calculatedContentSize = contentSize;
	return contentSize;
}

/**
 * Sets the zoom factor so the content fills the specified size.
 */
- (void)zoomToFitSize:(CGSize)fitSize animated:(BOOL)animated
{
	CGSize contentSize = _calculatedContentSize;	// We trust that intrinsicContentSize has been called.
	contentSize.width /= _zoomFactor;
	contentSize.height /= _zoomFactor;
	CGFloat widthFactor = fitSize.width / contentSize.width;
	CGFloat heightFactor = fitSize.height / contentSize.height;

	// Set zoom factor and invalidate content size and drawing
	self.zoomFactor = MIN( widthFactor, heightFactor );
	[self invalidateIntrinsicContentSize];
	[self setNeedsDisplay];

	if( animated )
	{
		[UIView animateWithDuration:0.3f animations:^{
			[self layoutIfNeeded];
		}];
	}
}

- (void)drawRect:(CGRect)rect
{
	// Fix the coordinate system so 0,0 is at bottom-left
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM( context, 0, self.bounds.size.height );
	CGContextScaleCTM( context, 1, -1 );

	// Offset by half the padding
	CGContextTranslateCTM( context, kViewPadding/2, kViewPadding/2 );

	// Set zoom level
	CGContextScaleCTM( context, self.zoomFactor, self.zoomFactor );

	// Adjust for origin (minimum coordinates)
	CGContextTranslateCTM( context, -_origin.x, -_origin.y );

	// Draw all instances, nets, busses and plain objects
	for( id<EAGLEDrawable> drawable in self.file.plainObjects )
		[drawable drawInContext:context];

	// Schematic-only objects
	if( [self.file isMemberOfClass:[EAGLESchematic class]] )
	{
		EAGLESchematic *schematic = (EAGLESchematic*)self.file;

		for( id<EAGLEDrawable> drawable in schematic.nets )
			[drawable drawInContext:context];

		for( id<EAGLEDrawable> drawable in schematic.busses )
			[drawable drawInContext:context];

		for( id<EAGLEDrawable> drawable in schematic.instances )
			[drawable drawInContext:context];
	}
	// Board-only objects
	else if( [self.file isMemberOfClass:[EAGLEBoard class]] )
	{
		EAGLEBoard *board = (EAGLEBoard*)self.file;

		// Signals
		for( EAGLESignal *signal in board.signals )
			[signal drawInContext:context];

		// Elements
		for( id<EAGLEDrawable> drawable in board.elements )
			[drawable drawInContext:context];
	}
}

- (NSArray*)objectsAtPoint:(CGPoint)point
{
	// <junction x="5.08" y="60.96"/>
	// - padding Coordinate: {5.1012878, 60.886848}
	// + padding Coordinate: {5.2144775, 60.996956}
	
	// Adjust coordinate for zoom factor, origin and padding

	// Flip Y axis
	CGPoint coordinate = point;
	coordinate.y = self.frame.size.height - point.y;

	// De-pad
	coordinate.x -= kViewPadding/2;
	coordinate.y -= kViewPadding/2;

	// Scale
	coordinate.x /= self.zoomFactor;
	coordinate.y /= self.zoomFactor;

	// Adjust for offset origin
	coordinate.x += _origin.x;
	coordinate.y += _origin.y;

	// Iterate all objects and find those with rect that encompass the point. Use the distance form the touch point to the center of the object as the key so we can sort by distance
	NSMutableDictionary *objectsAtCoordinate = [NSMutableDictionary dictionary];

	// Schematic-only objects
	if( [self.file isMemberOfClass:[EAGLESchematic class]] )
	{
		EAGLESchematic *schematic = (EAGLESchematic*)self.file;

		// Instances
		for( id<EAGLEDrawable> drawable in schematic.instances )
		{
			if( CGRectContainsPoint( [drawable boundingRect], coordinate ))
				objectsAtCoordinate[ distance( drawable, coordinate ) ] = drawable;
		}

		// Nets
		for( id<EAGLEDrawable> drawable in schematic.nets )
		{
			/// TODO
	//		if( [drawable maxX] >= coordinate.x && [drawable minX] <= coordinate.x &&
	//		    [drawable maxY] >= coordinate.y && [drawable minY] <= coordinate.y )
	//			objectsAtCoordinate[ distance( drawable, coordinate ) ] = drawable;
		}

		// Busses
		for( id<EAGLEDrawable> drawable in schematic.busses )
		{
			/// TODO
	//		if( [drawable maxX] >= coordinate.x && [drawable minX] <= coordinate.x &&
	//		    [drawable maxY] >= coordinate.y && [drawable minY] <= coordinate.y )
	//			objectsAtCoordinate[ distance( drawable, coordinate ) ] = drawable;
		}
	}

	// Board-only objects
	else if( [self.file isMemberOfClass:[EAGLEBoard class]] )
	{
		EAGLEBoard *board = (EAGLEBoard*)self.file;

		// Instances
		for( id<EAGLEDrawable> drawable in board.elements )
		{
			if( CGRectContainsPoint( [drawable boundingRect], coordinate ))
				objectsAtCoordinate[ distance( drawable, coordinate ) ] = drawable;
		}

		// Signals
		for( EAGLESignal *signal in board.signals )
		{
			/// TODO
		}
	}

	// Sort the objects by distance
	NSArray *sortedKeys = [[objectsAtCoordinate allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSArray *sortedValues = [objectsAtCoordinate objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];

	return sortedValues;
}

NSNumber* distance( id<EAGLEDrawable> drawable, CGPoint coordinate )
{
	CGFloat midX = ([drawable minX] + [drawable maxX]) / 2;
	CGFloat midY = ([drawable minY] + [drawable maxY]) / 2;

	midX = [drawable origin].x;
	midY = [drawable origin].y;
	
	CGFloat distance = sqrtf( powf( coordinate.x - midX, 2) + powf( coordinate.y - midY, 2 ));
	return @( distance );
}


@end
