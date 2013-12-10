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
	CGFloat _initialZoom;
	__block UIPopoverController *_popover;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicFile:@"iBeacon" error:&error];

	[self.schematicView setRelativeZoomFactor:0.1];
	_initialZoom = 0.1;
	self.schematicView.schematic = schematic;

	/// TEST: yellow bg color
	self.schematicView.backgroundColor = [UIColor yellowColor];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer
{
	// Remember schematic view's zoom factor when we begin zooming
	if( recognizer.state == UIGestureRecognizerStateBegan )
		_initialZoom = self.schematicView.zoomFactor;

	// Scale layer without recalculating or redrawing
	self.schematicView.layer.transform = CATransform3DMakeScale( recognizer.scale, recognizer.scale, 1 );

	// When pinch ends, multiply initial zoom factor by the gesture's scale to get final scale
	if( recognizer.state == UIGestureRecognizerStateEnded )
	{
		CGFloat finalZoom = _initialZoom * recognizer.scale;

		self.schematicView.layer.transform = CATransform3DIdentity;	// Reset transform since we're now changing the zoom factor to make a pretty redraw
		[self.schematicView setZoomFactor:finalZoom];				// And set new zoom factor
	}
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
	self.schematicView.layer.transform = CATransform3DIdentity;
	[UIView animateWithDuration:0.3 animations:^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[self.view layoutIfNeeded];
	}];
}

- (void)openFileFromURL:(NSURL*)fileURL
{
	// Make sure it's a file URL
	if( ![fileURL isFileURL] )
		[NSException raise:@"Invalid URL" format:@"Expected file URL: %@", [fileURL absoluteString]];

	NSString *filePath = [fileURL path];
	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicAtPath:filePath error:&error];
	NSAssert( error == nil, @"Error loading schematic: %@", [error localizedDescription] );

	self.schematicView.schematic = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
}

- (void)openSchematic:(EAGLESchematic*)schematic
{
	self.schematicView.schematic = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
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
