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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicFile:@"LED_resistor" error:&error];
	self.schematicView.schematic = schematic;

//	EAGLESchematicView *schematicView = [[EAGLESchematicView alloc] initWithFrame:self.view.bounds];
//	schematicView.schematic = schematic;
//	[self.view addSubview:schematicView];

	/*
	EAGLELibrary *library = schematic.libraries[ 0 ];
	EAGLESymbol *symbol = library.symbols[ 0 ];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[symbol image]];
	CGRect frame = imageView.frame;
	frame.origin = CGPointMake( 400, 0 );
	imageView.frame = frame;
	[self.view addSubview:imageView];


	library = schematic.libraries[ 1 ];
	symbol = library.symbols[ 0 ];
	imageView = [[UIImageView alloc] initWithImage:[symbol image]];
	frame = imageView.frame;
	frame.origin = CGPointMake( 400, 400 );
	imageView.frame = frame;
	[self.view addSubview:imageView];
	 */
}

@end
