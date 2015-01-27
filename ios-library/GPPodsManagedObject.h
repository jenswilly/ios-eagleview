//
//  GPPodsManagedObject.h
//  NHN
//
//  Created by Jens Willy Johannsen on 19/09/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GPPods.h"

@interface GPPodsManagedObject : NSManagedObject <GPPodsItem>

+ (void)refreshFromServer:(void(^)(NSArray *currentItems, NSArray *deletedItems))completionBlock checkDeletedItems:(BOOL)checkDeletedItems errorBlock:(void(^)(NSError *error))errorBlock;
+ (NSDictionary*)mappings;
+ (NSString*)uniqueKey;
//+ (NSDate *)parseRFC3339Date:(NSString *)dateString;

- (void)setURL:(NSURL*)url forKey:(NSString *)key;
- (NSURL*)URLForKey:(NSString *)key;
- (void)setArray:(NSArray*)array forKey:(NSString *)key;
- (NSArray*)arrayForKey:(NSString *)key;
- (void)setDictionary:(NSDictionary*)dictionary forKey:(NSString *)key;
- (NSDictionary*)dictionaryForKey:(NSString *)key;
- (void)deleteAllObjects;

- (void)setIsModified;	// Optional method which is called when updating so the object can invalidate caches etc.

@end
