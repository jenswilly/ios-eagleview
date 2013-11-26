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
		_zoomFactor = 10;	// Default zoom factor
    }

    return self;
}

- (void)awakeFromNib
{
	_zoomFactor = 10;
}

- (void)drawRect:(CGRect)rect
{
	// Fix the coordinate system so 0,0 is at bottom-left
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM( context, 0, self.bounds.size.height );
	CGContextScaleCTM( context, 1, -1 );

	// Set zoom level
	CGContextScaleCTM( context, self.zoomFactor, self.zoomFactor );

	/*
	/// TEMP: draw two symbols at hardcoded locations
	EAGLESymbol *symbol_3V3 = sparkFunLibrary.symbols[ 0 ];
	EAGLESymbol *symbol_GND = sparkFunLibrary.symbols[ 1 ];

	[symbol_GND drawAtPoint:CGPointMake( 2.54, 2.54 ) context:context];
	[symbol_3V3 drawAtPoint:CGPointMake( 2.54, 5.08 ) context:context];
	 */

	/// TEMP: draw all instances and nets
	for( id<EAGLEDrawable> drawable in self.schematic.instances )
		[drawable drawInContext:context];
	for( id<EAGLEDrawable> drawable in self.schematic.nets )
		[drawable drawInContext:context];
	for( id<EAGLEDrawable> drawable in self.schematic.busses )
		[drawable drawInContext:context];
}

@end
