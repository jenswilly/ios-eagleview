//
//  ComponentSearchViewController.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/02/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "ComponentSearchViewController.h"
#import "EAGLEFileView.h"
#import "EAGLEFile.h"
#import "EAGLEBoard.h"
#import "EAGLESchematic.h"
#import "EAGLEElement.h"
#import "EAGLEInstance.h"
#import "EAGLEPart.h"

#define DATAARRAY_IN_USE (_isSearching ? _filteredComponents : _allComponents)

@interface ComponentSearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ComponentSearchViewController
{
	NSArray *_filteredComponents;
	NSArray *_allComponents;
	BOOL _isSearching;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_selectedParts = [NSMutableArray array];

	[self.tableView registerNib:[UINib nibWithNibName:@"ComponentCell" bundle:nil] forCellReuseIdentifier:@"cell"];
//	self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)setFileView:(EAGLEFileView *)fileView
{
	_fileView = fileView;

	if( [_fileView.file isKindOfClass:[EAGLEBoard class]] )
	{
		NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
		_allComponents = [((EAGLEBoard*)self.fileView.file).elements sortedArrayUsingDescriptors:@[ sortByName ]];
	}
	else if( [_fileView.file isKindOfClass:[EAGLESchematic class]] )
	{
		NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
		_allComponents = [((EAGLESchematic*)self.fileView.file).instances sortedArrayUsingDescriptors:@[ sortByName ]];
	}

	[self.tableView reloadData];
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [DATAARRAY_IN_USE count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	id object = DATAARRAY_IN_USE[ indexPath.row ];
	if( [object isKindOfClass:[EAGLEElement class]] )
	{
		cell.textLabel.text = ((EAGLEElement*)object).name;
		cell.detailTextLabel.text = ((EAGLEElement*)object).value;
		cell.accessoryType = ( [self.selectedParts containsObject:object] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
	}
	else if( [object isKindOfClass:[EAGLEInstance class]] )
	{
		cell.textLabel.text = [((EAGLEInstance*)object) name];
		cell.detailTextLabel.text = [(EAGLEInstance*)object valueText];
		cell.accessoryType = ( [self.selectedParts containsObject:object] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = DATAARRAY_IN_USE[ indexPath.row ];

	// Select or deselect?
	if( [self.selectedParts containsObject:object] )
		// Already selected: deselect
		[_selectedParts removeObject:object];
	else
		// Select it
		[_selectedParts addObject:object];

	self.fileView.highlightedElements = _selectedParts;
	[tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Search methods

- (void)filterForSearchString:(NSString*)searchString
{
	if( [searchString length] == 0 )
		_filteredComponents = @[];
	else
	{
		NSPredicate *findByName = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR valueText CONTAINS[cd] %@", searchString, searchString];
		_filteredComponents = [_allComponents filteredArrayUsingPredicate:findByName];
	}

	// Reload
	[self.tableView reloadData];
}

#pragma mark - UISearchBar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self filterForSearchString:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	_isSearching = YES;
	[self filterForSearchString:@""];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	_isSearching = NO;
	[self.tableView reloadData];
}

@end
