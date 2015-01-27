//
//  DetailPopupViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "DetailPopupViewController.h"
#import "EAGLEPart.h"
#import "EAGLEPackage.h"
#import "EAGLESchematic.h"
#import "EAGLEInstanceView.h"

static const CGFloat kSettingsAnimationDuration = 0.3;	// Alpha of gray overlay view

@interface DetailPopupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet EAGLEInstanceView *instanceView;
@property (weak, nonatomic) IBOutlet UILabel *libraryLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTitleLabel;	// So we can show either "Device" or "Package"
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (assign) IBInspectable CGSize popupSize;	// IBInspectable property. Used only on iPhone where it should be set to the view's size in IB.

@end

@implementation DetailPopupViewController
{
	__weak UIViewController *_parentViewController;
	__weak UIView *_grayView;
	__weak UIView *_blurView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		// iPad: remove OK button. The preferred content size is set as a runtime attribute in the storyboard file.
		[self.okBtn removeFromSuperview];
	}
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (void)showAddedToViewController:(UIViewController*)parentViewController
{
	// Remember parent view controller and delegate
	_parentViewController = parentViewController;

	// Instantiate blur view
	UIVisualEffect *blurEffect;
	blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

	UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	visualEffectView.frame = _parentViewController.view.bounds;

	_blurView = visualEffectView;

	self.view.layer.cornerRadius = 8;
	_blurView.alpha = 0;

	// Add effect view to parent view controller's view
	[_parentViewController addChildViewController:self];
	[_parentViewController.view addSubview:visualEffectView];

	// Move self to parent view controller
	NSAssert( self.popupSize.width != 0 && self.popupSize.height != 0, @"Popup size *must* be set in IB. Use the same size as the view's freeform size." );
	self.view.frame = CGRectMake( 0, 0, self.popupSize.width, self.popupSize.height );
	self.view.center = visualEffectView.center;

	[visualEffectView.contentView addSubview:self.view];
	[self didMoveToParentViewController:self];

	// Constraints to set fixed size and centered X and Y to superview
	/*
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *views = @{ @"settings": self.view };
	NSAssert( self.popupSize.width != 0 && self.popupSize.height != 0, @"Popup size *must* be set in IB. Use the same size as the view's freeform size." );
	NSDictionary *metrics = @{ @"width": @( self.popupSize.width ), @"height": @( self.popupSize.height ) };
	[_parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[settings(width)]" options:0 metrics:metrics views:views]];
	[_parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[settings(height)]" options:0 metrics:metrics views:views]];
	[_parentViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_parentViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[_parentViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_parentViewController.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	*/

	[UIView animateWithDuration:kSettingsAnimationDuration animations:^{
		_blurView.alpha = 1;
	}];
}

- (void)dismiss
{
	// Note: this happens only on iPhone. On iPad, this view controller is presented as in a popover and the OK button is removed.
	[UIView animateWithDuration:kSettingsAnimationDuration animations:^{

		// Fade out views
		_blurView.alpha = 0;

	} completion:^(BOOL finished) {

		// Remove the gray view
		[_blurView removeFromSuperview];

		// Remove self
		[self willMoveToParentViewController:nil];
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	}];
}

- (void)setInstance:(EAGLEInstance *)instance
{
	// Make sure the view and IBOutlets are loaded
	[self view];

	self.typeLabel.text = [NSString stringWithFormat:@"%@ – %@", instance.part_name, [instance valueText]];
	self.nameLabel.text = instance.part_name;
	self.valueLabel.text = [instance valueText];

	// Get part
	EAGLEPart *part = [instance.schematic partWithName:instance.part_name];
	self.libraryLabel.text = part.library_name;
	
	NSString *deviceString;
	if( [part.device_name length] > 0 )
		deviceString = [NSString stringWithFormat:@"%@\r(%@)", part.deviceset_name, part.device_name];
	else
		deviceString = part.deviceset_name;
	self.deviceLabel.text = deviceString;

	self.deviceTitleLabel.text = @"Device";
}

- (void)setElement:(EAGLEElement *)element
{
	// Make sure the view and IBOutlets are loaded
	[self view];

	self.typeLabel.text = [NSString stringWithFormat:@"%@ – %@", element.name, element.value];
	self.nameLabel.text = element.name;
	self.valueLabel.text = element.value;
	self.libraryLabel.text = element.library_name;

	EAGLEPackage *package = element.package;
	self.deviceLabel.text = package.name;

	self.deviceTitleLabel.text = @"Package";
}

- (void)setModuleInstance:(EAGLEDrawableModuleInstance *)moduleInstance
{
	// Make sure the view and IBOutlets are loaded
	[self view];

	self.typeLabel.text = @"Module";
	self.nameLabel.text = moduleInstance.name;
	self.valueLabel.text = @"…";
	self.libraryLabel.text = @"…";
	self.deviceLabel.text = nil;
	self.deviceTitleLabel.text = nil;
}

@end
