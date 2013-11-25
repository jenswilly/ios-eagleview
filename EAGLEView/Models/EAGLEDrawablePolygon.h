//
//  EAGLEDrawablePolygon.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawable.h"

@interface EAGLEDrawablePolygon : EAGLEDrawable

@property (readonly) CGFloat width;
@property (readonly, strong) NSArray *vertices;		// Contains NSValues with CGPoints

@end
