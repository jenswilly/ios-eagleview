//
//  EAGLEModulePort.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDXMLElement;
@class EAGLEDrawableModuleInstance;
@class EAGLEFile;

typedef enum
{
	EAGLEModulePortSideLeft,
	EAGLEModulePortSideRight,
	EAGLEModulePortSideTop,
	EAGLEModulePortSideBottom
} EAGLEModulePortSide;

typedef enum
{
	EAGLEModulePortDirectionIO,
	EAGLEModulePortDirectionOther
} EAGLEModulePortDirection;

@interface EAGLEDrawableModulePort : NSObject

@property (readonly, strong) NSString *name;
@property (readonly) CGFloat position;
@property (readonly, strong) EAGLEFile *file;
@property (readonly) EAGLEModulePortSide side;
@property (readonly) EAGLEModulePortDirection direction;

- (id)initFromXMLElement:(DDXMLElement*)element inFile:(EAGLEFile*)file;
- (void)drawInContext:(CGContextRef)context moduleInstance:(EAGLEDrawableModuleInstance*)moduleInstance;

@end
