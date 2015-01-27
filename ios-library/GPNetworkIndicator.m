//
//  GPNetworkIndicator.m
//  Lighthouse
//
//  Created by Jens Willy Johannsen on 30/10/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPNetworkIndicator.h"

static int networkActivityCounter = 0;

@implementation GPNetworkIndicator

// Shows the network activity indicator
+ (void)show
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	});
	@synchronized( self )
	{
		networkActivityCounter++;
	}
}

// Hides the network activity indicator
+ (void)hide
{
	@synchronized( self )
	{
		networkActivityCounter--;
		if( networkActivityCounter < 0 )
			networkActivityCounter = 0;
	}

	// Hide indicator if done accessing
	if( networkActivityCounter == 0 )
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		});
	}
}

@end

