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
#import <DropboxSDK/DropboxSDK.h>
#import "Dropbox.h"
#import "DocumentChooserViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet EAGLESchematicView *schematicView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController
{
	CGFloat _lastZoom;
	__block UIPopoverController *_popover;
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
	if( recognizer.state == UIGestureRecognizerStateBegan )
		// Get current relative zoom
		_lastZoom = self.schematicView.relativeZoomFactor;
		
	// Add gesture's zoom to previous zoom
	CGFloat zoom = _lastZoom * recognizer.scale;
	if( zoom > 1 )
		zoom = 1;

	[self.schematicView setRelativeZoomFactor:zoom];

	if( recognizer.state == UIGestureRecognizerStateEnded )
		_lastZoom = zoom;
}

- (IBAction)chooseDocumentAction:(UIBarButtonItem*)sender
{
	// Authenticate if necessary
	if( ![[DBSession sharedSession] isLinked] )
	{
        [[DBSession sharedSession] linkFromController:self];
		return;
    }

	DEBUG_LOG( @"Dropbox already authenticated" );
	UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooserNavController"];
	_popover = [[UIPopoverController alloc] initWithContentViewController:navController];

	DocumentChooserViewController *documentChooserViewController = (DocumentChooserViewController*)navController.topViewController;
	documentChooserViewController.delegate = self;
	documentChooserViewController.path = @"/";

	[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)zoomToFitAction:(id)sender
{
	[UIView animateWithDuration:0.3 animations:^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
	}];
}

#pragma mark - Document Chooser Delegate methods

- (void)documentChooserPickedDropboxFile:(DBMetadata *)metadata
{
	DEBUG_LOG( @"Picked file: %@", [metadata description] );
	[_popover dismissPopoverAnimated:YES];

	// Show HUD and start loading
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	});

	[[Dropbox sharedInstance] loadFileAtPath:metadata.path completion:^(BOOL success, NSString *filePath) {

		if( success )
		{
			NSError *error = nil;
			EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicAtPath:filePath error:&error];
			NSAssert( error == nil, @"Error loading schematic: %@", [error localizedDescription] );

			self.schematicView.schematic = schematic;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
				[MBProgressHUD hideHUDForView:self.view animated:YES];
			});
		}
	}];
}

@end
