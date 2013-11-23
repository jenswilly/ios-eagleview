//
//  EAGLEDrawableText.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawable.h"

@interface EAGLEDrawableText : EAGLEDrawable

@property (readonly) CGPoint point;
@property (readonly, strong) NSString *text;
@property (readonly) CGFloat size;

@end
