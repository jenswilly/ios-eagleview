//
//  EAGLEModulePort.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 18/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDXMLElement;

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

@interface EAGLEModulePort : NSObject

@property (readonly, strong) NSString *name;
@property (readonly) CGFloat position;
@property (readonly) EAGLEModulePortSide side;
@property (readonly) EAGLEModulePortDirection direction;

- (id)initFromXMLElement:(DDXMLElement*)element;
- (void)drawInContext:(CGContextRef)context;

@end
