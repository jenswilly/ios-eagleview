//
//  GPPods.h
//  NHN
//
//  Created by Jens Willy Johannsen on 19/09/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPPodsItem <NSObject>

- (void)configureWithJSONDictionary:(NSDictionary*)dictionary;

@end

@interface GPPods : NSObject

+ (GPPods*)sharedInstance;
- (NSURL*)urlForAllEntriesForClass:(Class)class;
//- (NSURL*)urlForDeletedEntriesForClass:(Class)class;
- (void)registerURL:(NSURL*)url forClass:(Class)class;

@end
