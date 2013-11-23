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
#import "EAGLEDrawable.h"

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

- (void)drawRect:(CGRect)rect
{
	/// TEMP: test code to draw a single symbol.
	/// Need to add origin point to each symbol (actually to the parts)
	EAGLELibrary *library = self.schematic.libraries[ 0 ];
	EAGLESymbol *symbol = library.symbols[ 0 ];

	// Fix the coordinate system so 0,0 is at bottom-left
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM( context, 0, self.bounds.size.height );
	CGContextScaleCTM( context, 1, -1 );

	CGContextTranslateCTM( context, 50, 50 );

	// Set zoom level
	CGContextScaleCTM( context, self.zoomFactor, self.zoomFactor );

	// Iterate drawables
	for( EAGLEDrawable *drawable in symbol.components )
	{
		[drawable drawInContext:context];
	}
}

@end
