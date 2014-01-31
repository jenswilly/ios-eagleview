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
#import "EAGLESchematicView.h"
#import "EAGLEInstance.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Dropbox.h"
#import "DocumentChooserViewController.h"
#import "MBProgressHUD.h"
#import "UIView+AnchorPoint.h"
#import "DetailPopupViewController.h"
#import "LayersViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet EAGLESchematicView *schematicView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController
{
	__block UIPopoverController *_popover;
	NSString *_lastDropboxPath;		// Used to remember which Dropbox path the user was in last
	__block EAGLEFile *_eagleFile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSError *error = nil;
//	_eagleFile = [EAGLESchematic schematicFromSchematicFile:@"iBeacon" error:&error];
	_eagleFile = [EAGLEBoard boardFromBoardFile:@"Thermometer" error:&error];
	NSAssert( error == nil, @"Error loading file: %@", [error localizedDescription] );

	[self updateBackgroundAndStatusBar];

	[self.schematicView setRelativeZoomFactor:0.1];
	self.schematicView.file = _eagleFile;
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
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer*)recognizer
{
	if( recognizer.state == UIGestureRecognizerStateEnded )
	{
		// Find instance/net from schematic
		NSArray *objects = [self.schematicView objectsAtPoint:[recognizer locationInView:self.schematicView]];
		DEBUG_LOG( @"Touched %@", objects );

		if( [objects count] == 0 )
			return;
		
		id clickedObject = objects[ 0 ];
//		DEBUG_LOG( @"Clicked %@", clickedObject );

		if( [clickedObject isKindOfClass:[EAGLEInstance class]] )
		{
			DetailPopupViewController *detailPopupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPopupViewController"];
			detailPopupViewController.instance = clickedObject;
			[detailPopupViewController showAddedToViewController:self];
		}
		else if( [clickedObject isKindOfClass:[EAGLEElement class]] )
		{
			DetailPopupViewController *detailPopupViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPopupViewController"];
			detailPopupViewController.element = clickedObject;
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
		initialZoom = self.schematicView.zoomFactor;

		// Get coordinate in schematic view and convert to relative location (from 0-1 on both axes)
		CGPoint touchPoint = [recognizer locationInView:self.schematicView];
		relativeTouchInContent = CGPointMake( touchPoint.x / self.schematicView.bounds.size.width, touchPoint.y / self.schematicView.bounds.size.height);

		// Also remember pinch point in scroll view so we can set correct content offset when zooming ends
		touchPoint = [recognizer locationInView:self.scrollView];
		touchPoint.x -= self.scrollView.contentOffset.x;
		touchPoint.y -= self.scrollView.contentOffset.y;
		relativeTouchInScrollView = CGPointMake( touchPoint.x / self.scrollView.bounds.size.width, touchPoint.y / self.scrollView.bounds.size.height );

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
		self.scrollView.contentOffset = contentOffset;

		[self.view layoutIfNeeded];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (IBAction)showLayersAction:(UIBarButtonItem*)sender
{
	LayersViewController *layersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LayersViewController"];
	layersViewController.eagleFile = _eagleFile;
	layersViewController.fileView = self.schematicView;
	
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
	[documentChooserViewController setInitialPath:(_lastDropboxPath ? _lastDropboxPath : @"/" )];

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

	self.schematicView.file = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
}

- (void)openSchematic:(EAGLESchematic*)schematic
{
	self.schematicView.file = schematic;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
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

			[self updateBackgroundAndStatusBar];
			
			NSAssert( error == nil, @"Error loading file: %@", [error localizedDescription] );

			_eagleFile.fileName = fileName;
			_eagleFile.fileDate = fileDate;

			self.schematicView.file = _eagleFile;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.schematicView zoomToFitSize:self.scrollView.bounds.size animated:YES];
				[MBProgressHUD hideHUDForView:self.view animated:YES];
			});
		}
	}];
}

@end
