//
//  DocumentChooserViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "DocumentChooserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Dropbox.h"
#import "MBProgressHUD.h"

@interface DocumentChooserViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation DocumentChooserViewController
{
	NSArray *_contents;	// Contains DBMetadata objects
}

- (void)setPath:(NSString *)path
{
	_path = path;

	// Make sure view has been loaded
	[self view];
	
	// Set title
	self.navigationItem.title = _path;

	// Show HUD if not cached contents
	if( ![[Dropbox sharedInstance] hasCachedContentsForFolder:_path] )
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	// Load from Dropbox
	[[Dropbox sharedInstance] loadContentsForFolder:_path completion:^(BOOL success, NSArray *contents) {

		// Remove HUD (whether it is there or not)
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];

		if( success )
		{
			// Set contents
			_contents = contents;

			// Reload table on main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[_table reloadData];
			});
		}
		else
		{
			// Error loading
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Error loading contents from Dropbox" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
		}
	}];
}

#pragma mark - Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contents count];
}

// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Get the corresponding data object
	DBMetadata *metadata = _contents[ indexPath.row ];

    // Configure the cell
    cell.textLabel.text = metadata.filename;
	if( metadata.isDirectory )
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	// Get the item
	DBMetadata *metadata = _contents[ indexPath.row ];

	// File or folder?
	if( metadata.isDirectory )
	{
		// Folder: push new view controller onto the stack
		DocumentChooserViewController *documentChooserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooserViewController"];
		documentChooserViewController.path = metadata.path;
		documentChooserViewController.delegate = _delegate;
		[self.navigationController pushViewController:documentChooserViewController animated:YES];
	}
	else
	{
		// File: pass metadata back to view controller
		[_delegate documentChooserPickedDropboxFile:metadata];
	}
}

@end
