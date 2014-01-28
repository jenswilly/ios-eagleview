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

@interface LayersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation LayersViewController
{
	NSArray *_dataArray;	// Sorted array of layers. Sorting is done when setting the .eagleFile property
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
	NSSortDescriptor *sortByLayerNumber = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
	_dataArray = [[self.eagleFile.layers allValues] sortedArrayUsingDescriptors:@[ sortByLayerNumber ]];

	// Reload table
	[self.table reloadData];
}

#pragma mark - Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"cell";

    // Dequeue or create a new cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Get the corresponding data object
	EAGLELayer *layer = _dataArray[ indexPath.row ];

    // Configure the cell
    cell.textLabel.text = layer.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", layer.number];
	cell.imageView.image = [UIImage imageWithColor:layer.color size:CGSizeMake( 30, 30 )];

	// Is layer currently visible?
	/// TEMP
	if( indexPath.row % 3 == 0 )
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		// Not visible: add an empty view to align the detail labels in the cells
		cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, 24, 24 )];

    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	/// TODO: select/deselect layer
}

@end
