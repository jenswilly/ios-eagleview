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
#import "EAGLEBoard.h"
#import "EAGLEFileView.h"
#import "EAGLEInstance.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Dropbox.h"
#import "DocumentChooserViewController.h"
#import "MBProgressHUD.h"
#import "UIView+AnchorPoint.h"
#import "DetailPopupViewController.h"
#import "LayersViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet EAGLEFileView *fileView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpacingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@end

@implementation ViewController
{
	__block UIPopoverController *_popover;
	NSString *_lastDropboxPath;		// Used to remember which Dropbox path the user was in last
	__block EAGLEFile *_eagleFile;
	BOOL _fullScreen;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
//	_eagleFile = [EAGLESchematic schematicFromSchematicFile:@"iBeacon" error:&error];
	_eagleFile = [EAGLEBoard boardFromBoardFile:@"iBeacon" error:&error];
	NSAssert( error == nil, @"Error loading file: %@", [error localizedDescription] );

	[self updateBackgroundAndStatusBar];

	[self.fileView setRelativeZoomFactor:0.1];
	self.fileView.file = _eagleFile;

	// For iPhone: add gesture recognizer to enter/leave fullscreen mode
	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		// Get the normal tap recognizer
		UITapGestureRecognizer *singleTapRecognizer = self.fileView.gestureRecognizers[0];

		UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFullscreenTapGesture:)];
		doubleTapRecognizer.numberOfTapsRequired = 2;
		[self.view addGestureRecognizer:doubleTapRecognizer];

		[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
	}
	else
	{
		// iPad only: Configure file name label
		self.fileNameLabel.textColor = RGBHEX( GLOBAL_TINT_COLOR );
	}
}

- (void)updateBackgroundAndStatusBar
{
	// Set background colors and status bar style based on the type of file
	if( [_eagleFile isKindOfClass:[EAGLEBoard class]] )
	{
		self.view.backgroundColor = [UIColor blackColor];
		self.scrollView.backgroundColor = [UIColor blackColor];
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	}
	else
	{
		self.view.backgroundColor = [UIColor whiteColor];
		self.scrollView.backgroundColor = [UIColor whiteColor];
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
	}

	// Set file name label (iPad only)
	self.fileNameLabel.text = _eagleFile.fileName;
}

- (IBAction)handleFullscreenTapGesture:(UITapGestureRecognizer*)recognizer
{
	DEBUG_POSITION;

	// Toggle mode
	_fullScreen = !_fullScreen;
	[[UIApplication sharedApplication] setStatusBarHidden:_fullScreen withAnimation:UIStatusBarAnimationSlide];		// Show/hide status bar

	if( _fullScreen )
	{
		self.toolbarBottomSpacingConstraint.constant = 0;
	}
	else
	{
		self.toolbarBottomSpacingConstraint.constant = 44;
	}
	[UIView animateWithDuration:0.3 animations:^{
		[self.view layoutIfNeeded];
	}];
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer*)recognizer
{
	if( recognizer.state == UIGestureRecognizerStateEnded )
	{
		// Find instance/net from schematic
		NSArray *objects = [self.fileView objectsAtPoint:[recognizer locationInView:self.fileView]];
		DEBUG_LOG( @"Touched %@", objects );

		if( [objects count] == 0 )
			return;
		
		id clickedObject = objects[ 0 ];

		// Instantiate detail view controller and set current object property
		DetailPopupViewController *detailPopupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPopupViewController"];

		if( [clickedObject isKindOfClass:[EAGLEInstance class]] )
			detailPopupViewController.instance = clickedObject;
		else if( [clickedObject isKindOfClass:[EAGLEElement class]] )
			detailPopupViewController.element = clickedObject;

		// iPhone or iPad?
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
		{
			// iPad: show popover
			CGPoint pointInView = [_fileView eagleCoordinateToViewCoordinate:((EAGLEInstance*)clickedObject).origin];

			if( _popover )
				[_popover dismissPopoverAnimated:YES];
			_popover = [[UIPopoverController alloc] initWithContentViewController:detailPopupViewController];
			[_popover presentPopoverFromRect:CGRectMake( pointInView.x, pointInView.y, 2, 2) inView:self.fileView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
		{
			// iPhone: show modal
			[detailPopupViewController showAddedToViewController:self];
		}

	}
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer
{
	static CGFloat initialZoom;					// Static because we need this across several invocations of this method
	static CGPoint relativeTouchInContent;		// ʺ (that's right: a proper "double prime" character and not just a "straight quote")
	static CGPoint relativeTouchInScrollView;	// ʺ

	// Remember schematic view's zoom factor when we begin zooming
	if( recognizer.state == UIGestureRecognizerStateBegan )
	{
		initialZoom = self.fileView.zoomFactor;

		// Get coordinate in schematic view and convert to relative location (from 0-1 on both axes)
		CGPoint touchPoint = [recognizer locationInView:self.fileView];
		relativeTouchInContent = CGPointMake( touchPoint.x / self.fileView.bounds.size.width, touchPoint.y / self.fileView.bounds.size.height);

		// Also remember pinch point in scroll view so we can set correct content offset when zooming ends
		touchPoint = [recognizer locationInView:self.scrollView];
		touchPoint.x -= self.scrollView.contentOffset.x;
		touchPoint.y -= self.scrollView.contentOffset.y;
		relativeTouchInScrollView = CGPointMake( touchPoint.x / self.scrollView.bounds.size.width, touchPoint.y / self.scrollView.bounds.size.height );

		// Set layer's origin so scale transforms occur from this point
		[self.fileView setAnchorPoint:relativeTouchInContent];
	}

	// Scale layer without recalculating or redrawing
	self.fileView.layer.transform = CATransform3DMakeScale( recognizer.scale, recognizer.scale, 1 );

	// When pinch ends, multiply initial zoom factor by the gesture's scale to get final scale
	if( recognizer.state == UIGestureRecognizerStateEnded )
	{
		// These two lines prevent the "jumping" of the view that is probably caused by timing issues when changing the view's layer's transform, its zoom and the scroll view's content offset. But it *will* make a "flash".
		// From http://stackoverflow.com/questions/5198155/not-all-tiles-redrawn-after-catiledlayer-setneedsdisplay
		self.fileView.layer.contents = nil;
		[self.fileView.layer setNeedsDisplayInRect:self.fileView.layer.bounds];

		CGFloat finalZoom = initialZoom * recognizer.scale;

		[self.fileView setAnchorPoint:CGPointMake( 0.5, 0.5 )];
		self.fileView.layer.transform = CATransform3DIdentity;	// Reset transform since we're now changing the zoom factor to make a pretty redraw
		[self.fileView setZoomFactor:finalZoom];				// And set new zoom factor

		// Adjust content offset
		CGSize contentSize = [self.fileView intrinsicContentSize];
		CGPoint contentPoint = CGPointMake( relativeTouchInContent.x * contentSize.width, relativeTouchInContent.y * contentSize.height );
		CGPoint scrollPoint = CGPointMake( relativeTouchInScrollView.x * self.scrollView.bounds.size.width, relativeTouchInScrollView.y * self.scrollView.bounds.size.height );
		CGPoint contentOffset = CGPointMake( contentPoint.x - scrollPoint.x, contentPoint.y - scrollPoint.y );
		self.scrollView.contentOffset = contentOffset;

		[self.view layoutIfNeeded];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (IBAction)searchAction:(id)sender
{
	[self.fileView highlightPartWithName:@"D1"];
}

- (IBAction)showLayersAction:(UIBarButtonItem*)sender
{
	LayersViewController *layersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LayersViewController"];
	layersViewController.eagleFile = _eagleFile;
	layersViewController.fileView = self.fileView;
	
	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		// iPad: show as popover
		if( _popover )
			[_popover dismissPopoverAnimated:YES];
		
		_popover = [[UIPopoverController alloc] initWithContentViewController:layersViewController];
		[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
		// Place at bottom
		CGRect frame = layersViewController.view.frame;
		frame.origin.y = self.view.bounds.size.height;
		layersViewController.view.frame = frame;

		// Add view controller
		[self addChildViewController:layersViewController];
		[self.view addSubview:layersViewController.view];
		[layersViewController didMoveToParentViewController:self];

		// Animate to top
		frame.origin.y = 0;
		[UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			layersViewController.view.frame = frame;
		} completion:nil];
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
	DocumentChooserViewController *documentChooserViewController = (DocumentChooserViewController*)navController.topViewController;
	documentChooserViewController.delegate = self;

	// NOTE: _lastDropboxPath may be nil, in which case the DocumentChooserViewController will attempt to get path from user defaults
	[documentChooserViewController setInitialPath:_lastDropboxPath];

	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		// iPad: show as popover
		if( _popover )
			[_popover dismissPopoverAnimated:YES];

		_popover = [[UIPopoverController alloc] initWithContentViewController:navController];
		[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
		// iPhone: show modal
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (IBAction)zoomToFitAction:(id)sender
{
	self.fileView.layer.transform = CATransform3DIdentity;
	[UIView animateWithDuration:0.3 animations:^{
		[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
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

	self.fileView.file = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
}

- (void)openSchematic:(EAGLESchematic*)schematic
{
	self.fileView.file = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
}

#pragma mark - Document Chooser Delegate methods

- (void)documentChooserPickedDropboxFile:(DBMetadata *)metadata lastPath:(NSString*)lastPath
{
	DEBUG_LOG( @"Picked file: %@ from path: %@", [metadata description], lastPath );
	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
		// iPad: dismiss popover
		[_popover dismissPopoverAnimated:YES];

	// Remember last used path
	_lastDropboxPath = [lastPath copy];

	// Show HUD and start loading
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	});

	// Remember file data
	NSDate *fileDate = metadata.lastModifiedDate;
	NSString *fileName = [metadata.path lastPathComponent];
	[[Dropbox sharedInstance] loadFileAtPath:metadata.path completion:^(BOOL success, NSString *filePath) {

		if( success )
		{
			NSError *error;

			// Schematic or board?
			if( [[[fileName pathExtension] lowercaseString] isEqualToString:@"sch"] )
				_eagleFile = [EAGLESchematic schematicFromSchematicAtPath:filePath error:&error];
			else if( [[[fileName pathExtension] lowercaseString] isEqualToString:@"brd"] )
				_eagleFile = [EAGLEBoard boardFromBoardFileAtPath:filePath error:&error];

			_eagleFile.fileName = fileName;
			_eagleFile.fileDate = fileDate;

			[self updateBackgroundAndStatusBar];
			
			NSAssert( error == nil, @"Error loading file: %@", [error localizedDescription] );

			self.fileView.file = _eagleFile;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
				[MBProgressHUD hideHUDForView:self.view animated:YES];
			});
		}
	}];
}

@end
