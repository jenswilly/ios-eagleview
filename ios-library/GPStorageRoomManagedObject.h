//
//  GPStorageRoomManagedObject.h
//  iOS7 Test
//
//  Created by Jens Willy Johannsen on 21/06/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GPStorageRoom.h"

// typedef id (^mappingBlock_t)(NSDictionary *dictionary);

@interface GPStorageRoomManagedObject : NSManagedObject <GPStorageRoomItem>

+ (void)refreshFromServer:(void(^)(NSArray *currentItems, NSArray *deletedItems))completionBlock checkDeletedItems:(BOOL)checkDeletedItems errorBlock:(void(^)(NSError *error))errorBlock;
+ (NSDictionary*)mappings;
+ (NSString*)uniqueKey;

- (void)setURL:(NSURL*)url forKey:(NSString *)key;
- (NSURL*)URLForKey:(NSString *)key;
- (void)setArray:(NSArray*)array forKey:(NSString *)key;
- (NSArray*)ArrayForKey:(NSString *)key;
- (void)setDictionary:(NSDictionary*)dictionary forKey:(NSString *)key;
- (NSDictionary*)dictionaryForKey:(NSString *)key;
- (void)setIsModified;	// Optional method which is called when updating so the object can invalidate caches etc.

@end
