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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

NSString *const kUserDefaults_lastDropboxPath = @"kUserDefaults_lastDropboxPath";
NSString *const kUserDefaults_settingsKeepAlive = @"keep_awake";
NSString *const kUserDefaults_lastFilePath = @"lastFilePath";

@implementation AppDelegate
{
	NSMutableDictionary *_filePaths;	// Paths of acceptable files when opening a zip file
	NSString *_unzipDirectoryPath;		// Path of unzip directory
}

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
	// NOTE: next part has been removed (issue #5) since handleOpenURL: was called too. Regardless of whether the app was active or not. (Maybe this is an iOS 8 thing?)
//	NSURL *url = launchOptions[ UIApplicationLaunchOptionsURLKey ];
//	if( [url isFileURL] )
//		// Yes: open the file
//		[self openFileURL:url];

#ifdef FABRIC_API_KEY
	[Fabric with:@[CrashlyticsKit]];
	NSLog( @"Fabric API set" );
#else
	NSLog( @"No Fabric API key" );
#endif
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// Is it a file URL?
	if( [url isFileURL] )
		// Yes: open file
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
		_unzipDirectoryPath = [NSTemporaryDirectory() stringByAppendingString:@"unzip"];
		NSLog( @"Unzipping to %@", _unzipDirectoryPath );
		BOOL success = [SSZipArchive unzipFileAtPath:sourceFilePath toDestination:_unzipDirectoryPath];
		if( !success )
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Error unzipping archive." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Darnit", nil];
			[alert show];
			goto cleanup;
		}

		// Get all files recursively
		NSArray *files = [self recursiveFilesInDirectory:_unzipDirectoryPath];
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
			fileURLToOpen = [NSURL fileURLWithPath:[acceptableFiles firstObject]];

		// If we found more then one, show action sheet and let user select
		else if( [acceptableFiles count] > 0 )
		{
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose file" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
			actionSheet.delegate = self;

			// Remember file paths and add button titles
			_filePaths = [NSMutableDictionary dictionary];
			for( int i = 0; i < [acceptableFiles count]; i++ )
			{
				[actionSheet addButtonWithTitle:[acceptableFiles[ i ] lastPathComponent]];
				_filePaths[ @(i) ] = acceptableFiles[ i ];
			}

			// Add cancel button last and set cancel btn index
			[actionSheet addButtonWithTitle:@"Cancel"];
			actionSheet.cancelButtonIndex = [acceptableFiles count];

			[actionSheet showInView:_viewController.view];
		}
		else if( [acceptableFiles count] == 0 )
		{
			// No acceptable files: show alert
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No .brd or .sch files found in archive." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Too bad", nil];
			[alert show];
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

	// Remove unzipped directory if present _and_ if we have a file to open
	if( _unzipDirectoryPath && fileURLToOpen )
	{
		[[NSFileManager defaultManager] removeItemAtPath:_unzipDirectoryPath error:&error];
		if( error )
			NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );
		_unzipDirectoryPath = nil;
	}

	// Delete zip file from inbox
cleanup:
	[[NSFileManager defaultManager] removeItemAtPath:[fileURL path] error:&error];
	if( error )
		NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );

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

	// Get path
	NSString *path = _filePaths[ @(buttonIndex) ];
	NSURL *fileURLToOpen = [NSURL fileURLWithPath:path];

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
			schematic.fileName = [path lastPathComponent];
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
			board.fileName = [path lastPathComponent];
			[self.viewController openFile:board];
		}
	}

	// Remove unzipped directory if present
	if( _unzipDirectoryPath )
	{
		[[NSFileManager defaultManager] removeItemAtPath:_unzipDirectoryPath error:&error];
		if( error )
			NSLog( @"Error removing file from unzip directory: %@", [error localizedDescription] );
		_unzipDirectoryPath = nil;
	}
}

- (NSArray*)recursiveFilesInDirectory:(NSString*)initialPath
{
	NSMutableArray *files = [NSMutableArray array];

	for( NSString *item in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:initialPath error:nil] )
	{
		NSString *path = [initialPath stringByAppendingPathComponent:item];
		BOOL isDirectory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];

		// If it is a directory, add contents. Otherwise, add the file
		if( isDirectory )
			[files addObjectsFromArray:[self recursiveFilesInDirectory:path]];
		else
			[files addObject:path];
	}

	return [NSArray arrayWithArray:files];
}

@end


