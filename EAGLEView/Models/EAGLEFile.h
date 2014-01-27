//
//  EAGLEFile.h
//  
//
//  Created by Jens Willy Johannsen on 27/01/14.
//
//

#import "EAGLEObject.h"
@class EAGLELibrary;

@interface EAGLEFile : EAGLEObject
{
	NSArray *_libraries;
	NSArray *_plainObjects;
}

@property (strong) NSDictionary *layers;
@property (readonly, strong) NSArray *libraries;
@property (readonly, strong) NSArray *plainObjects;	// Contains id<EAGLEDrawable> objects. This represents "plain" objects like texts or lines
@property (copy) NSString *fileName;
@property (copy) NSDate *fileDate;

- (EAGLELibrary*)libraryWithName:(NSString*)name;
- (NSString*)dateString;

@end
