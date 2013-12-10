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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Get reference to main view controller
	_viewController = (ViewController*)self.window.rootViewController;

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
	
	// Add whatever other url handling code your app requires here
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
		NSLog( @"Error reading schematic from file %@: %@", [fileURLToOpen absoluteString], [error localizedDescription] );

	// Delete file from inbox
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
	[self.viewController openSchematic:schematic];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
