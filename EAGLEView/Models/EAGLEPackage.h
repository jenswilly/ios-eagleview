//
//  EAGLEPackage.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 27/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"

@interface EAGLEPackage : EAGLEObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *components;	// Contains EAGLEDrawables
@property (strong) NSDictionary *textsForPlaceholders;
@property (strong) NSArray *placeholdersToSkip;	// Array of placeholder texts to ignore. This is used when an attribute is smashed which means we'll draw it directly from the symbol

- (void)drawInContext:(CGContextRef)context smashed:(BOOL)smashed mirrored:(BOOL)mirrored;
- (void)drawInContext:(CGContextRef)context smashed:(BOOL)smashed mirrored:(BOOL)mirrored layerNumber:(NSNumber*)layerNumber;
- (CGFloat)maxX;
- (CGFloat)maxY;
- (CGFloat)minX;
- (CGFloat)minY;

@end
