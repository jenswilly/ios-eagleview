//
//  EAGLESymbol.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"

@interface EAGLESymbol : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) id components;
@property (strong) NSDictionary *textsForPlaceholders;
@property (strong) NSArray *placeholdersToSkip;	// Array of placeholder texts to ignore. This is used when an attribute is smashed which means we'll draw it directly from the symbol

- (void)drawAtPoint:(CGPoint)origin context:(CGContextRef)context;

@end
