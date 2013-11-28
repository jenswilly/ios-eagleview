//
//  EAGLEAttribute.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 26/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLEDrawableObject.h"

@interface EAGLEAttribute : EAGLEDrawableObject <EAGLEDrawable>

@property (readonly, strong) NSString *name;
@property (readonly) CGPoint point;
@property (readonly) CGFloat size;
@property (readonly) CGFloat rotation;
@property (strong) NSString *text;

@end
