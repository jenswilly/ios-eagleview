//
//  EAGLEDrawableText.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

extern const CGFloat kFontSizeFactor;

@interface EAGLEDrawableText : EAGLEDrawableObject

@property (readonly) CGPoint point;
@property (readonly, strong) NSString *text;
@property (readonly) CGFloat size;
@property (readonly) Rotation rotation;
@property (weak) NSString *valueText;

- (void)drawInContext:(CGContextRef)context flipText:(BOOL)flipText isMirrored:(BOOL)isMirrored;

@end
