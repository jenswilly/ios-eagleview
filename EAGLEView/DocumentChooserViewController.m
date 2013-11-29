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
#import "ProgressHUD.h"

@interface DocumentChooserViewController ()

@end

@implementation DocumentChooserViewController

#pragma mark - Table methods

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
		[ProgressHUD show:nil];
		[[Dropbox sharedInstance] loadContentsForFolder:metadata.path completion:^(BOOL success, NSArray *contents) {

			[ProgressHUD dismiss];
			DEBUG_LOG( @"Dropbox load metadata %@", (success ? @"successful" : @"FAILED") );
			if( success )
			{
				DocumentChooserViewController *documentChooserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooserViewController"];
				documentChooserViewController.title = metadata.filename;
				documentChooserViewController.contents = contents;
				documentChooserViewController.delegate = _delegate;
				[self.navigationController pushViewController:documentChooserViewController animated:YES];
			}
		}];
	}
	else
	{
		// File: pass metadata back to view controller
		[_delegate documentChooserPickedDropboxFile:metadata];
	}
}

@end
