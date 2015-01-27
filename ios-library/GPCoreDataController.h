//
//  GPCoreDateController.h
//  iOS7 Test
//
//  Created by Jens Willy Johannsen on 21/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GPCoreDataController : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Methods
+ (GPCoreDataController*)sharedInstance;
- (void)saveContext;

@end
