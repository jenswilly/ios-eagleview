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

#define DATAARRAY_IN_USE (tableView == self.searchDisplayController.searchResultsTableView ? _filteredComponents : _allComponents)

@interface ComponentSearchViewController ()

@end

@implementation ComponentSearchViewController
{
	NSArray *_filteredComponents;
	NSArray *_allComponents;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.tableView registerNib:[UINib nibWithNibName:@"ComponentCell" bundle:nil] forCellReuseIdentifier:@"cell"];
	self.tableView.backgroundColor = [UIColor whiteColor];

	[self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ComponentCell" bundle:nil] forCellReuseIdentifier:@"cell"];
	self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
	self.searchDisplayController.searchResultsTableView.allowsMultipleSelection = YES;
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
		[NSException raise:@"Not implemented" format:nil];	///

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
		cell.selected = ([self.selectedParts containsObject:object]);
		cell.accessoryType = ( [self.selectedParts containsObject:object] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateWithSelectedElementsFromTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateWithSelectedElementsFromTableView:tableView];
}

- (void)updateWithSelectedElementsFromTableView:(UITableView*)tableView
{
	if( [self.fileView.file isKindOfClass:[EAGLEBoard class]] )
	{
		// Convert selected index paths to an index set
		NSArray *selectedIndexes = [tableView indexPathsForSelectedRows];
		NSMutableIndexSet *selectedIndexSet = [NSMutableIndexSet indexSet];
		for( NSIndexPath *indexPath in selectedIndexes )
			[selectedIndexSet addIndex:indexPath.row];

		NSArray *selectedElements = [DATAARRAY_IN_USE objectsAtIndexes:selectedIndexSet];
		self.fileView.highlightedElements = selectedElements;
	}
}

#pragma mark - Search methods

- (void)filterForSearchString:(NSString*)searchString
{
	NSPredicate *findByName = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
	_filteredComponents = [_allComponents filteredArrayUsingPredicate:findByName];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterForSearchString:searchString];
	return YES;
}

@end
