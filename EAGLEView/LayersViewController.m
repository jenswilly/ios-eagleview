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

#pragma mark - Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sortedLayerKeys count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"cell";

    // Dequeue or create a new cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Get the corresponding data object
	NSNumber *layerNumber = _sortedLayerKeys[ indexPath.row ];
	EAGLELayer *layer = self.eagleFile.layers[ layerNumber ];

    // Configure the cell
    cell.textLabel.text = layer.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", layer.number];
	cell.imageView.image = [UIImage imageWithColor:layer.color size:CGSizeMake( 30, 30 )];

	// Is layer currently visible?
	if( layer.visible )
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		// Not visible: add an empty view to align the detail labels in the cells
		cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 24, 24 )];

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	/// TODO: select/deselect layer
	NSNumber *layerNumber = _sortedLayerKeys[ indexPath.row ];
	EAGLELayer *layer = self.eagleFile.layers[ layerNumber ];
	layer.visible = !layer.visible;

	// Reload cell
	[_table reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

	// Redraw
	[_fileView setNeedsDisplay];
}

@end
