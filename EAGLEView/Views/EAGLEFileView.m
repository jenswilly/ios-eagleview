//
//  EAGLEFileView.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEFileView.h"
#import "EAGLESymbol.h"
#import "EAGLELibrary.h"
#import "EAGLEDrawableObject.h"
#import "EAGLEInstance.h"
#import "EAGLENet.h"
#import "EAGLESchematic.h"
#import "EAGLEBoard.h"
#import "EAGLESignal.h"
#import "EAGLEElement.h"
#import "FastTiledLayer.h"

static const CGFloat kViewPadding = 5;
static const int kTileSize = 2048;
static const CGFloat kHighlightLineWidth = 0.6;	// Width (not zoom dependant) of frame around highlighted components
#define HIGHLIGHT_COLOR [UIColor yellowColor]	// UIColor to use for highlight frame

@implementation EAGLEFileView
{
	BOOL _needsCalculateIntrinsicContentSize;
	NSArray *_highlightedComponents;	// Contains either EAGLEElements or EAGLEInstances
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		_minZoomFactor = 1;
		_maxZoomFactor = 100;
		self.zoomFactor = 15;	// Default zoom factor

		((FastTiledLayer*)self.layer).tileSize = CGSizeMake( kTileSize, kTileSize );	// Set tile size
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

	((FastTiledLayer*)self.layer).tileSize = CGSizeMake( kTileSize, kTileSize );
}

- (NSUInteger)highlightPartWithName:(NSString *)name
{
	NSPredicate *findByName = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *found;

	if( [self.file isKindOfClass:[EAGLEBoard class]] )
	{
		// Board: find a matching element
		found = [((EAGLEBoard*)self.file).elements filteredArrayUsingPredicate:findByName];
		_highlightedComponents = found;
		[self setNeedsDisplay];	/// Change to only relevant rect
	}

	// Return number of matching components
	return [found count];
}

- (void)highlightElements:(NSArray*)elements
{
	_highlightedComponents = elements;
	[self setNeedsDisplay];	/// Change to only relevant rect
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

+ layerClass
{
	return [FastTiledLayer class];
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


	///

	// Iterate active layers
	for( NSNumber *layerNumber in self.file.orderedLayerKeys )
	{
		// Skip if layer not visible
		EAGLELayer *layer = self.file.layers[ layerNumber ];
		if( !layer.visible )
			continue;
		
		for( id<EAGLEDrawable> drawable in self.file.drawablesInLayers[ layerNumber ] )
			[drawable drawInContext:context];

		// For boards, also draw elements for this layer
		if( [self.file isMemberOfClass:[EAGLEBoard class]] )
		{
			EAGLEBoard *board = (EAGLEBoard*)self.file;
			for( EAGLEElement *element in board.elements )
				[element drawInContext:context layerNumber:layerNumber];
		}

		// For schematics, draw instances for this layer
		else if( [self.file isMemberOfClass:[EAGLESchematic class]] )
		{
			EAGLESchematic *schematic = (EAGLESchematic*)self.file;
			for( EAGLEInstance *instance in schematic.instances )
				[instance drawInContext:context layerNumber:layerNumber];
		}
	}

	// Highlighted components
	for( EAGLEElement *element in _highlightedComponents )
	{
		CGContextSetStrokeColorWithColor( context, HIGHLIGHT_COLOR.CGColor );
		CGContextSetLineWidth( context, kHighlightLineWidth );
		CGContextStrokeRect( context, [element boundingRect] );
	}
}

- (NSArray*)objectsAtPoint:(CGPoint)point
{
	// <junction x="5.08" y="60.96"/>
	// - padding Coordinate: {5.1012878, 60.886848}
	// + padding Coordinate: {5.2144775, 60.996956}

	// Convert to EAGLE coordinate
	CGPoint coordinate = [self viewCoordinateToEagleCoordinate:point];

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

- (CGPoint)eagleCoordinateToViewCoordinate:(CGPoint)point
{
	// Adjust for offset origin
	CGPoint coordinate = point;

	coordinate.x -= _origin.x;
	coordinate.y -= _origin.y;

	// Scale
	coordinate.x *= self.zoomFactor;
	coordinate.y *= self.zoomFactor;

	// De-pad
	coordinate.x += kViewPadding/2;
	coordinate.y += kViewPadding/2;

	// Flip Y axis
	coordinate.y = self.frame.size.height - coordinate.y;

	return coordinate;
}

- (CGPoint)viewCoordinateToEagleCoordinate:(CGPoint)point
{
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

	return coordinate;
}

@end
