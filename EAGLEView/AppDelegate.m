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

NSString *const kUserDefaults_lastDropboxPath = @"kUserDefaults_lastDropboxPath";

@implementation AppDelegate

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

	// Is it a .sch file?
	if( [[[fileURL pathExtension] lowercaseString] isEqualToString:@"sch"] )
		// Yes: open it directly
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

		for( NSString *file in files )
		{
			if( [[file.pathExtension lowercaseString] isEqualToString:@"sch"] )
			{
				// Found one: open it (if there are more than one, the rest will be ignored)
				fileURLToOpen = [NSURL fileURLWithPath:[destinationPath stringByAppendingPathComponent:file]];
				break;
			}
		}

	}

	// Read schematic
	NSError *error = nil;
	EAGLESchematic *schematic = [EAGLESchematic schematicFromSchematicAtPath:[fileURLToOpen path] error:&error];
	if( error )
	{
		NSLog( @"Error reading schematic from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not open schematic file. This application can only open EAGLE version 6+ files." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
	}

	// Delete zip file from inbox
	[[NSFileManager defaultManager] removeItemAtPath:[fileURL path] error:&error];
	if( error )
		NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );

	// Remove unzipped directory if present
	if( destinationPath )
	{
		[[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&error];
		if( error )
			NSLog( @"Error removing file from inbox %@: %@", [fileURL absoluteString], [error localizedDescription] );
	}

	// Show the schematic
	if( schematic )
		[self.viewController openSchematic:schematic];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAppearance
{
	self.window.backgroundColor = [UIColor whiteColor];

	// Global tint color
	self.window.tintColor = RGBHEX( GLOBAL_TINT_COLOR );
	[[UISwitch appearance] setOnTintColor:RGBHEX( GLOBAL_TINT_COLOR )];
}


@end
