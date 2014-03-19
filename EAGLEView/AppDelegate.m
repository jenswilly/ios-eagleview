//
//  AppDelegate.m
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ViewController.h"
#import "SSZipArchive.h"
#import "EAGLESchematic.h"
#import "EAGLEBoard.h"

NSString *const kUserDefaults_lastDropboxPath = @"kUserDefaults_lastDropboxPath";
NSString *const kUserDefaults_settingsKeepAlive = @"keep_awake";

@implementation AppDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{ kUserDefaults_settingsKeepAlive: @YES }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Get reference to main view controller
	_viewController = (ViewController*)self.window.rootViewController;

	[self setAppearance];

	// Start Dropbox session
	DBSession* dbSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
	[DBSession setSharedSession:dbSession];

	// Are we opened in response to a "Open in…"?
	NSURL *url = launchOptions[ UIApplicationLaunchOptionsURLKey ];
	if( [url isFileURL] )
		// Yes: open the file
		[self openFileURL:url];

    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// Is it a file URL?
	if( [url isFileURL] )
		// Yes: open schematic file
		[self openFileURL:url];
	else if( [[DBSession sharedSession] handleOpenURL:url] )
	{
		// Otherwise, check if it is a Dropbox authentication URL
		if( [[DBSession sharedSession] isLinked] )
			DEBUG_LOG( @"Dropbox authenticated" );

		return YES;
	}
	
	// Otherwise, we don't know what it is
	return NO;
}

- (void)openFileURL:(NSURL*)fileURL
{
	NSURL *fileURLToOpen = nil;
	NSString *destinationPath = nil;
	NSError *error = nil;

	// Is it a .sch file?
	if( [[[fileURL pathExtension] lowercaseString] isEqualToString:@"sch"] )
		// Yes: open it directly
		fileURLToOpen = fileURL;
	else if( [[[fileURL pathExtension] lowercaseString] isEqualToString:@"brd"] )
		// Board file: open it directly
		fileURLToOpen = fileURL;
	else if( [[[fileURL pathExtension] lowercaseString] isEqualToString:@"zip"] )
	{
		// It is a zip file: extract and see if we can find a .sch file in the archive
		NSString *sourceFilePath = [fileURL path];
		destinationPath = [NSTemporaryDirectory() stringByAppendingString:@"unzip"];
		DEBUG_LOG( @"Unzipping to %@", destinationPath );
		[SSZipArchive unzipFileAtPath:sourceFilePath toDestination:destinationPath];

		// Iterate files in archive
		NSError *error;
		NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:&error];
		if( files == nil )
		{
			NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
			return;
		}

		NSMutableArray *acceptableFiles = [NSMutableArray arrayWithCapacity:[files count]];
		for( NSString *file in files )
		{
			if( [[file.pathExtension lowercaseString] isEqualToString:@"sch"] || [[file.pathExtension lowercaseString] isEqualToString:@"brd"] )
				[acceptableFiles addObject:file];
		}

		// If we found only one acceptable file, we'll use that
		if( [acceptableFiles count] == 1 )
			fileURLToOpen = [NSURL fileURLWithPath:[destinationPath stringByAppendingPathComponent:acceptableFiles[0]]];

		// If we found more then one, show action sheet and let user select
		else if( [acceptableFiles count] > 0 )
		{
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose file" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
			actionSheet.delegate = self;
			for( NSString *file in acceptableFiles )
				[actionSheet addButtonWithTitle:file];

			// Add cancel button last and set cancel btn index
			[actionSheet addButtonWithTitle:@"Cancel"];
			actionSheet.cancelButtonIndex = [acceptableFiles count];

			[actionSheet showInView:_viewController.view];
		}
	}

	// Which kind of file is it?
	if( [[[fileURLToOpen pathExtension] lowercaseString] isEqualToString:@"sch"] )
	{
		// Read schematic
		EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicAtPath:[fileURLToOpen path] error:&error];
		if( error )
		{
			NSLog( @"Error reading schematic from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open schematic file. This application can only open EAGLE version 6+ files." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
		}

		// Show the schematic
		if( schematic )
			[self.viewController openFile:schematic];
	}
	else if( [[[fileURLToOpen pathExtension] lowercaseString] isEqualToString:@"brd"] )
	{
		// Read board
		EAGLEBoard *board = [EAGLEBoard boardFromBoardFileAtPath:[fileURLToOpen path] error:&error];
		if( error )
		{
			NSLog( @"Error reading board from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open board file. This application can only open EAGLE version 6+ files." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
		}

		// Show the schematic
		if( board )
			[self.viewController openFile:board];
	}

	// Delete zip file from inbox
	[[NSFileManager defaultManager] removeItemAtPath:[fileURL path] error:&error];
	if( error )
		NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );

	// Remove unzipped directory if present
	/*
	if( destinationPath )
	{
		[[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&error];
		if( error )
			NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );
	}
	*/
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Enable or disable idle timer
	BOOL keepAwake = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaults_settingsKeepAlive];
	[UIApplication sharedApplication].idleTimerDisabled = keepAwake;
	DEBUG_LOG( @"Idle timer %@", (keepAwake ? @"disabled" : @"enabled"));
}

- (void)setAppearance
{
	self.window.backgroundColor = [UIColor whiteColor];

	// Global tint color
	self.window.tintColor = RGBHEX( GLOBAL_TINT_COLOR );
	[[UISwitch appearance] setOnTintColor:RGBHEX( GLOBAL_TINT_COLOR )];
}

#pragma mark UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Return immediately if it was the cancel button
	if( buttonIndex == actionSheet.cancelButtonIndex )
		return;

	// Construct path
	NSString *fileName = [actionSheet buttonTitleAtIndex:buttonIndex];
	NSURL *fileURLToOpen = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingString:@"unzip"] stringByAppendingPathComponent:fileName]];

	// Open file
	NSError *error = nil;
	if( [[[fileURLToOpen pathExtension] lowercaseString] isEqualToString:@"sch"] )
	{
		// Read schematic
		EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicAtPath:[fileURLToOpen path] error:&error];
		if( error )
		{
			NSLog( @"Error reading schematic from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open schematic file. This application can only open EAGLE version 6+ files." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
		}

		// Show the schematic
		if( schematic )
		{
			schematic.fileName = fileName;
			[self.viewController openFile:schematic];
		}
	}
	else if( [[[fileURLToOpen pathExtension] lowercaseString] isEqualToString:@"brd"] )
	{
		// Read board
		EAGLEBoard *board = [EAGLEBoard boardFromBoardFileAtPath:[fileURLToOpen path] error:&error];
		if( error )
		{
			NSLog( @"Error reading board from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open board file. This application can only open EAGLE version 6+ files." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
		}

		// Show the schematic
		if( board )
		{
			board.fileName = fileName;
			[self.viewController openFile:board];
		}
	}
}


@end
