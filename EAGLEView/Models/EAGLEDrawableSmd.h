//
//  EAGLEDrawableSmd.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 29/01/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

@interface EAGLEDrawableSmd : EAGLEDrawableObject

@property (readonly) CGPoint point;
@property (readonly) CGSize size;
@property (readonly, strong) NSString *name;
@property (readonly) CGFloat roundness;
@property (readonly) Rotation rotation;
@end
