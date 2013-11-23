//
//  EAGLEDrawablePin.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawable.h"

typedef enum
{
	EAGLEDrawablePinLength_Short,
	EAGLEDrawablePinLength_Medium,
	EAGLEDrawablePinLength_Long
} EAGLEDrawablePinLength;

@interface EAGLEDrawablePin : EAGLEDrawable

@property (readonly) CGPoint point;
@property (readonly, strong) NSString *name;
@property (readonly) EAGLEDrawablePinLength length;
@property (readonly) CGFloat rotation;

@end
