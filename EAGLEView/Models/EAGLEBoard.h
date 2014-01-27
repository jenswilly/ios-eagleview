//
//  EAGLEBoard.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEFile.h"
@class EAGLEPackage;

@interface EAGLEBoard : EAGLEFile

@property (readonly, strong) NSArray *elements;		// Boards: elements

+ (instancetype)boardFromBoardFile:(NSString *)boardFileName error:(NSError *__autoreleasing *)error;
+ (instancetype)boardFromBoardFileAtPath:(NSString*)path error:(NSError *__autoreleasing *)error;

- (EAGLEPackage*)packageNamed:(NSString*)packageName inLibraryNamed:(NSString*)libraryName;

@end
