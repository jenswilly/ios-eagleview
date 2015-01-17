//
//  EAGLEModuleInstance.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import "EAGLEDrawableObject.h"
@class EAGLEModule;

#define MODULE_INSTANCE_LAYER @90

@interface EAGLEDrawableModuleInstance : EAGLEDrawableObject

@property (readonly) CGFloat width;
@property (readonly) CGFloat height;
@property (readonly) CGPoint center;
@property (readonly) Rotation rotation;
@property (readonly, strong) NSString *name;
@property (readonly, strong) EAGLEModule *module;

@end
