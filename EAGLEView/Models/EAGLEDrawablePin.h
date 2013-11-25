//
//  EAGLEDrawablePin.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"

typedef enum
{
	EAGLEDrawablePinLength_Short,
	EAGLEDrawablePinLength_Medium,
	EAGLEDrawablePinLength_Long
} EAGLEDrawablePinLength;

@interface EAGLEDrawablePin : EAGLEDrawableObject

@property (readonly) CGPoint point;
@property (readonly, strong) NSString *name;
@property (readonly) EAGLEDrawablePinLength length;
@property (readonly) CGFloat rotation;

@end
