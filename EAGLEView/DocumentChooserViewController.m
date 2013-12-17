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

- (void)setItem:(DBMetadata *)item
{
	_item = item;

	// Make sure view has been loaded
	[self view];
	
	// Show HUD if not cached contents
	if( ![[Dropbox sharedInstance] hasCachedContentsForFolder:_item.path] )
	{
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];

		// Set title to Loading…
		self.navigationItem.title = @"Loading…";
	}
	else
		// Set title immediately
		self.navigationItem.title = _item.filename;

	// Load from Dropbox
	[[Dropbox sharedInstance] loadContentsForFolder:_item.path completion:^(BOOL success, NSArray *contents) {

		// Remove HUD (whether it is there or not) and set title (possibly again)
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		self.navigationItem.title = _item.filename;

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

/**
 * Sets the initial path to display contents for.
 * This method will create view controllers for all the individual path components from / up to the current path and
 * push them on the navigation stack.
 *
 * If you want to just display contents for a single, specific folder, use -[DocumentChooserViewController setPath:] instead.
 *
 * @param	path	The path to navigate to.
 */
- (void)setInitialPath:(NSString*)path
{
	// Split path into components
	NSArray *pathComponents = [path pathComponents];
	DEBUG_LOG( @"Navigating to %@", [pathComponents description] );

	// Set first path on self
	self.path = [pathComponents firstObject];

	// If we have more, iterate them and create and push new instances
	for( int i = 1; i < [pathComponents count]; i++ )
	{
		// Construct full path for this element
		NSString *path = [@"/" stringByAppendingString:[[pathComponents subarrayWithRange:NSMakeRange( 1, i )] componentsJoinedByString:@"/"]];
		DocumentChooserViewController *documentChooseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooserViewController"];
		documentChooseViewController.path = path;
		[self.navigationController pushViewController:documentChooseViewController animated:NO];
	}
}

- (void)setPath:(NSString *)path
{
	_path = path;

	// Make sure view has been loaded
	[self view];

	// Show HUD if not cached contents
	DEBUG_LOG( @"Checking for cached contents for %@", _path );
	if( ![[Dropbox sharedInstance] hasCachedContentsForFolder:_path] )
	{
		DEBUG_LOG( @"Contents *not* cached for %@", _path );
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];

		// Set title to Loading…
		self.navigationItem.title = @"Loading…";
	}
	else
	{
		DEBUG_LOG( @"Contents *not* cached for %@", _path );

		// Set title immediately
		self.navigationItem.title = _path;
	}

	// Load from Dropbox
	[[Dropbox sharedInstance] loadContentsForFolder:_path completion:^(BOOL success, NSArray *contents) {

		// Remove HUD (whether it is there or not) and set title (possibly again)
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		self.navigationItem.title = _path;

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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error loading contents from Dropbox" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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
		documentChooserViewController.item = metadata;
		documentChooserViewController.delegate = _delegate;
		[self.navigationController pushViewController:documentChooserViewController animated:YES];
	}
	else
	{
		// File: pass metadata back to view controller
		[_delegate documentChooserPickedDropboxFile:metadata lastPath:[metadata.path stringByDeletingLastPathComponent]];
	}
}

@end
