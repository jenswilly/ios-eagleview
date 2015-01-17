//
//  EAGLEInstance.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 25/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import "EAGLEObject.h"
#import "EAGLEDrawableObject.h"
@class EAGLESymbol;
@class EAGLEPart;
@class EAGLEModule;

@interface EAGLEInstance : EAGLEObject <EAGLEDrawable>

@property (readonly, strong) NSString *part_name;
@property (readonly, strong) NSString *gate_name;
@property (readonly) CGPoint point;
@property (readonly) BOOL smashed;
@property (readonly) Rotation rotation;
@property (readonly, strong) NSDictionary *smashedAttributes;

- (id)initFromXMLElement:(DDXMLElement *)element inFile:(EAGLEFile *)file module:(EAGLEModule*)module;
- (EAGLESymbol*)symbol;
- (EAGLEPart*)part;
- (NSString*)name;	// Return the part's name
- (NSString*)valueText;
- (void)drawInContext:(CGContextRef)context layerNumber:(NSNumber*)layerNumber;

@end
