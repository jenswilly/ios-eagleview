//
//  EAGLEModule.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 17/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EAGLESheet;
@class EAGLEPart;
@class EAGLESchematic;
@class DDXMLElement;

@interface EAGLEModule : NSObject

@property (copy) NSString *name;
@property (readonly, strong) NSArray *parts;			// Module: Contains EAGLEPart objects
@property (readonly, strong) NSArray *sheets;			// Contains EAGLEModule objects
@property (readonly, weak) EAGLESheet *activeSheet;		// The currently selected sheet

- (id)initFromXMLElement:(DDXMLElement*)element schematic:(EAGLESchematic*)schematic;
- (EAGLEPart*)partWithName:(NSString *)name;

@end
