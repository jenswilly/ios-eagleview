//
//  ModulesViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 19/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "ModulesViewController.h"
#import "EAGLESchematic.h"
#import "EAGLEModule.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface ModulesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ModulesViewController

- (IBAction)dismiss:(id)sender
{
	CGRect frame = self.view.frame;
	frame.origin.y = self.view.bounds.size.height;

	[UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

		self.view.frame = frame;

	} completion:^(BOOL finished) {

		[self willMoveToParentViewController:nil];
		[self.view removeFromSuperview];
		[self removeFromParentViewController];

	}];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		// iPhone: adjust view size when rotating (why doesn't this happen automatically? Probably because the view has been added manually as a subview)
		self.view.frame = self.parentViewController.view.bounds;
	}
}

#pragma mark - Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.schematic.modules count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *cellIdentifier = @"cell";

	// Dequeue or create a new cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	// Get the corresponding data object
	EAGLEModule *module = self.schematic.modules[ indexPath.row ];

	// Configure the cell
	cell.textLabel.text = ([module.name length] > 0 ? module.name : self.schematic.fileName);

	cell.accessoryType = (self.schematic.currentModuleIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

	return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSInteger oldIndex = self.schematic.currentModuleIndex;
	self.schematic.currentModuleIndex = indexPath.row;

	// Reload relevant cells

	NSArray *cellsToReload = @[ [NSIndexPath indexPathForRow:oldIndex inSection:0], [NSIndexPath indexPathForRow:indexPath.row inSection:0] ];
	[self.table reloadRowsAtIndexPaths:cellsToReload withRowAnimation:UITableViewRowAnimationFade];

	// Update label
	NSString *name;
	if( [[self.schematic activeModule].name length] > 0 )
		name = [NSString stringWithFormat:@"%@ – %@", self.schematic.fileName, [self.schematic activeModule].name];
	else
		name = self.schematic.fileName;

	APP.viewController.fileNameLabel.text = name;

	// Redraw
	[APP.viewController.fileView setNeedsDisplay];

	// Zoom-to-fit
	dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC ), dispatch_get_main_queue(), ^{
		[APP.viewController zoomToFitAction:nil];
	});

	// Dismiss
	

}

@end
