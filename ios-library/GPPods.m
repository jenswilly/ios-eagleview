//
//  GPPods.m
//  NHN
//
//  Created by Jens Willy Johannsen on 19/09/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "GPPods.h"

@implementation GPPods
{
	NSMutableDictionary *_classesCollectionsDictionary;	// Keeps associations between class names and URLs. Use -[GPPods registerURL:forClass:] to register URLs.
}

+ (GPPods*)sharedInstance
{
    static dispatch_once_t once;
    static GPPods *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
	if( (self = [super init]) )
	{
		// Initialize classes-collections dictionary
		_classesCollectionsDictionary = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (NSURL *)urlForAllEntriesForClass:(Class)class
{
	// Return URL for class
	return _classesCollectionsDictionary[ NSStringFromClass( class )];
}

- (void)registerURL:(NSURL *)url forClass:(Class)class
{
	// Insert (or overwrite) collection ID for class
	[_classesCollectionsDictionary setObject:url forKey:NSStringFromClass(class)];
}

@end
