//
//  GPStorageRoom.h
//  iOS7 Test
//
//  Created by Jens Willy Johannsen on 21/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPStorageRoomItem <NSObject>

- (void)configureWithJSONDictionary:(NSDictionary*)dictionary;

@end

@interface GPStorageRoom : NSObject

@property (copy) NSString *accountID;
@property (copy) NSString *authToken;

+ (GPStorageRoom*)sharedInstance;
- (NSURL*)urlForAllEntriesInCollection:(NSString*)collectionID;
- (NSURL*)urlForAllEntriesForClass:(Class)class;
- (NSURL*)urlForDeletedEntriesInCollection:(NSString*)collectionID;
- (NSURL*)urlForDeletedEntriesForClass:(Class)class;
- (void)registerCollectionID:(NSString*)collectionID forClass:(Class)class;

@end
