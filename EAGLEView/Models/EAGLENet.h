//
//  EAGLENet.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"

@interface EAGLENet : EAGLEObject <EAGLEDrawable>

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSArray *wires;	// Contains EAGLENet objects. NOTE: segments have abstracted away from the model
@property (readonly, strong) NSArray *labels;	// Contains EAGLEDrawableText objects where the valueText property has been set to the name of the net/bus

@end
