//
//  ViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "ViewController.h"
#import "EAGLEObject.h"
#import "EAGLELayer.h"
#import "EAGLELibrary.h"
#import "EAGLESymbol.h"
#import "EAGLESchematic.h"
#import "EAGLESchematicView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet EAGLESchematicView *schematicView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController
{
	CGFloat _lastZoom;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicFile:@"iBeacon" error:&error];

	[self.schematicView setRelativeZoomFactor:0.1];
	_lastZoom = 0.1;
	self.schematicView.schematic = schematic;
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer
{
	// Add gesture's zoom to previous zoom
	CGFloat zoom = _lastZoom * recognizer.scale;
	if( zoom > 1 )
		zoom = 1;

	[self.schematicView setRelativeZoomFactor:zoom];

	if( recognizer.state == UIGestureRecognizerStateEnded )
		_lastZoom = zoom;
}

@end
