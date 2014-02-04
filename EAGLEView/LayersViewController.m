//
//  LayersViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 28/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "LayersViewController.h"
#import "EAGLEFile.h"
#import "EAGLELayer.h"
#import "AppDelegate.h"
#import "UIImage+Color.h"
#import "EAGLESchematicView.h"

@interface LayersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation LayersViewController
{
	NSArray *_sortedLayerKeys;	// Sorted keys for layers dictionary. Sorting is done when setting the .eagleFile property
}

- (void)viewDidLoad
{
	// Fix table separator
	self.table.separatorColor = RGBHEX( GLOBAL_TINT_COLOR );
	self.table.separatorInset = UIEdgeInsetsMake( 0, 15, 0, 15 );
}

- (void)setEagleFile:(EAGLEFile *)eagleFile
{
	_eagleFile = eagleFile;

	// Sort layers
	_sortedLayerKeys = [[self.eagleFile.layers allKeys] sortedArrayUsingSelector:@selector(compare:)];

	// Reload table
	[self.table reloadData];
}

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

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if( section == 0 )
		return 2;	// Always 2 cells in first section
	else
		return [_sortedLayerKeys count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"cell";

    // Dequeue or create a new cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	// For section 0, we have two hardcoded cells
	if( indexPath.section == 0 )
	{
		cell.detailTextLabel.text = nil;
		cell.imageView.image = nil;
		cell.accessoryView = nil;
		
		if( indexPath.row == 0 )
		{
			cell.textLabel.text = @"All top layers";
			cell.accessoryType = ( [self.eagleFile allTopLayersVisible] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone );
		}
		else if( indexPath.row == 1 )
		{
			cell.textLabel.text = @"All bottom layers";
			cell.accessoryType = ( [self.eagleFile allBottomLayersVisible] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone );
		}
	}
	else
	{
		// Get the corresponding data object
		NSNumber *layerNumber = _sortedLayerKeys[ indexPath.row ];
		EAGLELayer *layer = self.eagleFile.layers[ layerNumber ];

		// Configure the cell
		cell.textLabel.text = layer.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", layer.number];
		cell.imageView.image = [UIImage imageWithColor:layer.color size:CGSizeMake( 30, 30 )];

		// Is layer currently visible?
		if( layer.visible )
		{
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else
		{
			// Not visible: add an empty view to align the detail labels in the cells
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 24, 24 )];
		}
	}

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	// Special case for section 0 which is all top/all bottom
	if( indexPath.section == 0 )
	{
		// Make an array of all relevant layers
		NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];

		if( indexPath.row == 0 )
		{
			// Top layers. Toggle visiblilty
			BOOL visible = ![self.eagleFile allTopLayersVisible];

			// Set on all relevant layers
			for( NSNumber *layerNumber in TOP_LAYERS )
			{
				((EAGLELayer*)self.eagleFile.layers[ layerNumber ]).visible = visible;

				// Add index path
				NSUInteger index = [_sortedLayerKeys indexOfObject:layerNumber];
				[indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:1]];
			}
		}
		else if( indexPath.row == 1 )
		{
			// Bottom layers. Toggle visiblilty
			BOOL visible = ![self.eagleFile allBottomLayersVisible];

			// Set on all relevant layers
			for( NSNumber *layerNumber in BOTTOM_LAYERS )
			{
				((EAGLELayer*)self.eagleFile.layers[ layerNumber ]).visible = visible;

				// Add index path
				NSUInteger index = [_sortedLayerKeys indexOfObject:layerNumber];
				[indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:1]];
			}
		}

		[_table reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else
	{
		// Section 1: individual layers
		NSNumber *layerNumber = _sortedLayerKeys[ indexPath.row ];
		EAGLELayer *layer = self.eagleFile.layers[ layerNumber ];
		layer.visible = !layer.visible;

		// Reload cell and section 0 cells
		[_table reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:0 inSection:0],
										  [NSIndexPath indexPathForItem:1 inSection:0],
										  indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
	}

	// Redraw file
	[_fileView setNeedsDisplay];
}

@end
