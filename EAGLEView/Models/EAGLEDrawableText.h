//
//  EAGLEDrawableText.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

@interface EAGLEDrawableText : EAGLEDrawableObject

@property (readonly) CGPoint point;
@property (readonly, strong) NSString *text;
@property (readonly) CGFloat size;
@property (readonly) CGFloat rotation;
@property (weak) NSString *valueText;

@end
