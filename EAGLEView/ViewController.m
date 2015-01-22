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
#import "EAGLEInstance.h"
#import "EAGLEModule.h"
#import "EAGLEDrawableModuleInstance.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Dropbox.h"
#import "DocumentChooserViewController.h"
#import "MBProgressHUD.h"
#import "UIView+AnchorPoint.h"
#import "DetailPopupViewController.h"
#import "LayersViewController.h"
#import "AppDelegate.h"
#import "ComponentSearchViewController.h"
#import "ModulesViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;

@end

@implementation ViewController
{
	__block UIPopoverController *_popover;
	__block EAGLEFile *_eagleFile;
	BOOL _fullScreen;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Show placeholder image
	self.placeholderImageView.hidden = NO;

	// Initialize file view. We have to initialize with a valid file. Otherwise the drawing context is messed up (for some reason).
	NSError *error = nil;

	_eagleFile = [EAGLEBoard boardFromBoardFile:@"" error:&error];	// Empty board
	//_eagleFile = [EAGLESchematic schematicFromSchematicFile:@"" error:&error];	// Empty schematic
	//_eagleFile = [EAGLESchematic schematicFromSchematicFile:@"#2014-003_Powerpack" error:&error];
	//_eagleFile = [EAGLEBoard boardFromBoardFile:@"Gift card" error:nil];

	_eagleFile.fileName = @"";
	_eagleFile.fileDate = [NSDate date];
	NSAssert( error == nil, @"Error loading file: %@", [error localizedDescription] );
	[self.fileView setRelativeZoomFactor:0.1];
	self.fileView.file = _eagleFile;

	dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC ), dispatch_get_main_queue(), ^{
		[self zoomToFitAction:nil];
	});

	[self updateBackgroundAndStatusBar];

	// Add double tap recognizer (NB: behaves differently on iPad/iPhone – see the handler method
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
	doubleTapRecognizer.numberOfTapsRequired = 2;
	[self.view addGestureRecognizer:doubleTapRecognizer];

	// Coordinate double tap and single tap recognizers
	UITapGestureRecognizer *singleTapRecognizer = self.fileView.gestureRecognizers[0];
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

	// iPad only: Configure file name label
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
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
	NSString *name = self.fileView.file.fileName;	// Default name is the file name. If it is a schematic, see if we need to show module name
	if( [self.fileView.file isKindOfClass:[EAGLESchematic class]] )
	{
		EAGLESchematic *schematic = (EAGLESchematic*)self.fileView.file;
		if( [[schematic activeModule].name length] > 0 )
			name = [NSString stringWithFormat:@"%@ – %@", schematic.fileName, [schematic activeModule].name];
	}

	self.fileNameLabel.text = name;
}

/**
 This method checks if a double tap is on a module instance and handles it.
 
 @param recognizer	The UITapGestureRecognizer to check
 @return Returns YES if the double tap was handled; NO if there is no double tap on a module instance.
 */
- (BOOL)handleDoubleTapOnModuleInstance:(UITapGestureRecognizer*)recognizer
{
	if( [self.fileView.file isKindOfClass:[EAGLESchematic class]] )
	{
		id<EAGLEDrawable> tappedObject = [[self.fileView objectsAtPoint:[recognizer locationInView:self.fileView]] firstObject];
		if( [tappedObject isKindOfClass:[EAGLEDrawableModuleInstance class]] )
		{
			EAGLESchematic *schematic = (EAGLESchematic*)self.fileView.file;	// Typecast
			for( int i = 0; i < schematic.modules.count; i++ )
			{
				EAGLEModule *module = schematic.modules[ i ];
				if( [module.name isEqualToString:((EAGLEDrawableModuleInstance*)tappedObject).module.name] )
				{
					schematic.currentModuleIndex = i;

					// Update label
					NSString *name;
					if( [[schematic activeModule].name length] > 0 )
						name = [NSString stringWithFormat:@"%@ – %@", schematic.fileName, [schematic activeModule].name];
					else
						name = schematic.fileName;

					self.fileNameLabel.text = name;

					// Redraw
					[self.fileView setNeedsDisplay];

					// Zoom-to-fit
					dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC ), dispatch_get_main_queue(), ^{
						[self zoomToFitAction:nil];
					});

					return YES;	// Yes, we have handled the double tap
				}
			}
		}
	}

	return NO;	// No, we haven't handled it
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer*)recognizer
{
	// If we're showing a schematic and the user double-tapped on a module instance, then jump to the module instead of toggling fullscreen
	if( [self handleDoubleTapOnModuleInstance:recognizer] )
		return;

	// For iPad, do nothing else here
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
		return;

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
		else if( [clickedObject isKindOfClass:[EAGLEDrawableModuleInstance class]] )
			detailPopupViewController.moduleInstance = clickedObject;

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
	ComponentSearchViewController *componentSearchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ComponentSearchViewController"];
	componentSearchViewController.fileView = self.fileView;
	if( [self.fileView.highlightedElements count] > 0 )
		componentSearchViewController.selectedParts = [self.fileView.highlightedElements mutableCopy];

	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		// iPad: show as popover
		if( _popover )
			[_popover dismissPopoverAnimated:YES];

		_popover = [[UIPopoverController alloc] initWithContentViewController:componentSearchViewController];
		[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
		[NSException raise:@"Not implemented" format:nil];
}

- (IBAction)sheetsAction:(id)sender
{
	ModulesViewController *modulesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ModulesViewController"];
	modulesViewController.schematic = (EAGLESchematic*)_eagleFile;

	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		// iPad: show as popover
		if( _popover )
			[_popover dismissPopoverAnimated:YES];

		_popover = [[UIPopoverController alloc] initWithContentViewController:modulesViewController];
		[_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
		// iPhone: we'add it manually so we can use a transparent background.
		// Place at bottom
		CGRect frame = self.view.bounds;
		frame.origin.y = self.view.bounds.size.height;
		modulesViewController.view.frame = frame;

		// Add view controller
		[self addChildViewController:modulesViewController];
		[self.view addSubview:modulesViewController.view];
		[modulesViewController didMoveToParentViewController:self];

		// Animate to top
		frame.origin.y = 0;
		[UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			modulesViewController.view.frame = frame;
		} completion:nil];
	}
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
		// iPhone: we'add it manually so we can use a transparent background.
		// Place at bottom
		CGRect frame = self.view.bounds;
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
	[documentChooserViewController setInitialPath:self.lastDropboxPath];

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
	self.placeholderImageView.hidden = YES;	// Hide initial placeholder

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
	});
}

- (void)openFile:(EAGLEFile*)file
{
	_eagleFile = file;
	[self updateBackgroundAndStatusBar];
	self.fileView.file = file;
	self.placeholderImageView.hidden = YES;	// Hide initial placeholder
	
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
	self.lastDropboxPath = lastPath;

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
			self.placeholderImageView.hidden = YES;	// Hide initial placeholder

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.fileView zoomToFitSize:self.scrollView.bounds.size animated:YES];
				[MBProgressHUD hideHUDForView:self.view animated:YES];
			});
		}
	}];
}

- (void)documentChooserCancelled
{
	// Simply close popover (iPad only)
	[_popover dismissPopoverAnimated:YES];
}

@end
