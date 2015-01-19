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
#import "AppDelegate.h"
#import "ViewController.h"

@interface DocumentChooserViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation DocumentChooserViewController
{
	NSArray *_contents;	// Contains DBMetadata objects
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Fix table separator
	self.table.separatorColor = RGBHEX( GLOBAL_TINT_COLOR );
	self.table.separatorInset = UIEdgeInsetsMake( 0, 15, 0, 15 );
}

- (void)viewDidAppear:(BOOL)animated
{
	// If we have a valid Dropbox item and no path set, we don't need to load since loading is already in progress (from setItem:).
	if( _item && !_path )
	{
		// Just set path
		_path = _item.path;
		return;
	}

	// Otherwise, load from the path
	BOOL usingPathFromUserDefaults = NO;

	// If nil path, try to get from user defaults
	if( !_path )
	{
		_path = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_lastDropboxPath];

		if( _path )
			usingPathFromUserDefaults = YES;
		else
			// Still nil: use /
			_path = @"/";
	}

	// Show HUD if not cached contents
	if( ![[Dropbox sharedInstance] hasCachedContentsForFolder:_path] )
	{
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];

		// Set title to Loading…
		self.navigationItem.title = @"Loading…";
	}
	else
		// Set title immediately
		self.navigationItem.title = _path.lastPathComponent;

	// Load from Dropbox
	[[Dropbox sharedInstance] loadContentsForFolder:_path completion:^(BOOL success, NSArray *contents) {

		// Remove HUD (whether it is there or not) and set title (possibly again)
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		self.navigationItem.title = _path.lastPathComponent;

		// If we got an error while using a saved path, reset to / and try again
		if( !success && usingPathFromUserDefaults )
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setInitialPath:@"/"];
				//				self.path = @"/";
			});

			return ;
		}

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
	[super viewDidAppear:animated];
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
	// If nil path, try to get from user defaults
	if( !path )
		path = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_lastDropboxPath];

	// Split path into components
	NSArray *pathComponents = [path pathComponents];

	// Set first path on self
	self.path = [pathComponents firstObject];

	// If we have more, iterate them and create and push new instances
	for( int i = 1; i < [pathComponents count]; i++ )
	{
		// Construct full path for this element
		NSString *path = [@"/" stringByAppendingString:[[pathComponents subarrayWithRange:NSMakeRange( 1, i )] componentsJoinedByString:@"/"]];
		DocumentChooserViewController *documentChooseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentChooserViewController"];
		documentChooseViewController.path = path;
		documentChooseViewController.delegate = _delegate;
		[self.navigationController pushViewController:documentChooseViewController animated:NO];
	}
}

- (IBAction)dismiss:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)signOutAction:(id)sender
{
	[[Dropbox sharedInstance] reset];
	[[DBSession sharedSession] unlinkAll];
	[[Dropbox sharedInstance] reset];
	APP.viewController.lastDropboxPath = nil;
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaults_lastDropboxPath];

	// iPhone or iPad?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
		// iPad: dismiss popover
		[_delegate documentChooserCancelled];
	else
		// iPhone: dismiss self
		[self dismiss:nil];
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
//	self.table.separatorColor = RGBHEX( GLOBAL_TINT_COLOR );
//	return cell;
	
	if( metadata.isDirectory )
	{
		// Directory
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.tintColor = RGBHEX( GLOBAL_TINT_COLOR );
		cell.imageView.image = [[UIImage imageNamed:@"ico_folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	else
	{
		// File
		cell.accessoryType = UITableViewCellAccessoryNone;

		// Set cell style based on file extension
		if( [[[metadata.filename pathExtension] lowercaseString] isEqualToString:@"sch"] )
		{
			// Schematic file
			cell.textLabel.textColor = RGBHEX( GLOBAL_TINT_COLOR );
			cell.imageView.tintColor = RGBHEX( GLOBAL_TINT_COLOR );
			cell.imageView.image = [[UIImage imageNamed:@"ico_file_schematic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		else if( [[[metadata.filename pathExtension] lowercaseString] isEqualToString:@"brd"] )
		{
			// Board file (can't be selected yet)
			cell.textLabel.textColor = RGBHEX( GLOBAL_TINT_COLOR );
			cell.imageView.tintColor = RGBHEX( GLOBAL_TINT_COLOR );
			cell.imageView.image = [[UIImage imageNamed:@"ico_file_board"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		else
		{
			cell.textLabel.textColor = [UIColor grayColor];
			cell.imageView.tintColor = [UIColor grayColor];
			cell.imageView.image = [[UIImage imageNamed:@"ico_file_generic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
	}


    return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the item
	DBMetadata *metadata = _contents[ indexPath.row ];

	// File or directory
	if( metadata.isDirectory )
		// Directory: go ahead and select
		return indexPath;
	else
	{
		// File: check extension
		if( [[[metadata.filename pathExtension] lowercaseString] isEqualToString:@"sch"] || [[[metadata.filename pathExtension] lowercaseString] isEqualToString:@"brd"] )
			// Schematic or board file: OK
			return indexPath;
		else
			// Other file: cannot select
			return nil;
	}
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

		// Remember path in user defaults
		[[NSUserDefaults standardUserDefaults] setObject:[metadata.path stringByDeletingLastPathComponent] forKey:kUserDefaults_lastDropboxPath];

		// iPhone or iPad?
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
			// iPhone: dismiss modal
			[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
