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
#import "UIView+AnchorPoint.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet EAGLESchematicView *schematicView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController
{
	__block UIPopoverController *_popover;
	NSString *_lastDropboxPath;		// Used to remember which Dropbox path the user was in last
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicFile:@"iBeacon" error:&error];

	[self.schematicView setRelativeZoomFactor:0.1];
	self.schematicView.schematic = schematic;

	/// TEST: yellow bg color
	//self.schematicView.backgroundColor = [UIColor yellowColor];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer
{
	static CGFloat initialZoom;					// Static because we need this across several invocations of this method
	static CGPoint relativeTouchInContent;		// ʺ (that's right: a proper "double prime" character and not just a "straight quote")
	static CGPoint relativeTouchInScrollView;	// ʺ

	// Remember schematic view's zoom factor when we begin zooming
	if( recognizer.state == UIGestureRecognizerStateBegan )
	{
		initialZoom = self.schematicView.zoomFactor;

		// Get coordinate in schematic view and convert to relative location (from 0-1 on both axes)
		CGPoint touchPoint = [recognizer locationInView:self.schematicView];
		relativeTouchInContent = CGPointMake( touchPoint.x / self.schematicView.bounds.size.width, touchPoint.y / self.schematicView.bounds.size.height);

		// Also remember pinch point in scroll view so we can set correct content offset when zooming ends
		touchPoint = [recognizer locationInView:self.scrollView];
		touchPoint.x -= self.scrollView.contentOffset.x;
		touchPoint.y -= self.scrollView.contentOffset.y;
		relativeTouchInScrollView = CGPointMake( touchPoint.x / self.scrollView.bounds.size.width, touchPoint.y / self.scrollView.bounds.size.height );

		DEBUG_LOG( @"Relative touch in content: %@, relative touch in scroll view: %@", NSStringFromCGPoint( relativeTouchInContent ), NSStringFromCGPoint( relativeTouchInScrollView ));

		///
		DEBUG_LOG( @"Actual content offset: %@", NSStringFromCGPoint( self.scrollView.contentOffset ));
		CGSize contentSize = [self.schematicView intrinsicContentSize];
		CGPoint contentPoint = CGPointMake( relativeTouchInContent.x * contentSize.width, relativeTouchInContent.y * contentSize.height );
		CGPoint scrollPoint = CGPointMake( relativeTouchInScrollView.x * self.scrollView.bounds.size.width, relativeTouchInScrollView.y * self.scrollView.bounds.size.height );
		CGPoint contentOffset = CGPointMake( contentPoint.x - scrollPoint.x, contentPoint.y - scrollPoint.y );
		DEBUG_LOG( @"Calculated content offset: %@", NSStringFromCGPoint( contentOffset ));
		///

		// Set layer's origin so scale transforms occur from this point
		[self.schematicView setAnchorPoint:relativeTouchInContent];
	}

	// Scale layer without recalculating or redrawing
	self.schematicView.layer.transform = CATransform3DMakeScale( recognizer.scale, recognizer.scale, 1 );

	// When pinch ends, multiply initial zoom factor by the gesture's scale to get final scale
	if( recognizer.state == UIGestureRecognizerStateEnded )
	{
		CGFloat finalZoom = initialZoom * recognizer.scale;

		[self.schematicView setAnchorPoint:CGPointMake( 0.5, 0.5 )];
		self.schematicView.layer.transform = CATransform3DIdentity;	// Reset transform since we're now changing the zoom factor to make a pretty redraw
		[self.schematicView setZoomFactor:finalZoom];				// And set new zoom factor

		// Adjust content offset
		CGSize contentSize = [self.schematicView intrinsicContentSize];
		CGPoint contentPoint = CGPointMake( relativeTouchInContent.x * contentSize.width, relativeTouchInContent.y * contentSize.height );
		CGPoint scrollPoint = CGPointMake( relativeTouchInScrollView.x * self.scrollView.bounds.size.width, relativeTouchInScrollView.y * self.scrollView.bounds.size.height );
		CGPoint contentOffset = CGPointMake( contentPoint.x - scrollPoint.x, contentPoint.y - scrollPoint.y );
		DEBUG_LOG( @"New calculated content offset: %@", NSStringFromCGPoint( contentOffset ));
		self.scrollView.contentOffset = contentOffset;

		[self.view layoutIfNeeded];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	DEBUG_LOG( @"Content offset: %@", NSStringFromCGPoint( self.scrollView.contentOffset ));
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
	[documentChooserViewController setInitialPath:(_lastDropboxPath ? _lastDropboxPath : @"/" )];

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

- (void)documentChooserPickedDropboxFile:(DBMetadata *)metadata lastPath:(NSString*)lastPath
{
	DEBUG_LOG( @"Picked file: %@ from path: %@", [metadata description], lastPath );
	[_popover dismissPopoverAnimated:YES];

	// Remember last used path
	_lastDropboxPath = [lastPath copy];

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
