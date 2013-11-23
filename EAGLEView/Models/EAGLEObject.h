//
//  EAGLEObject.h
//  EAGLEView
//
//  Created by Jens Willy Johannsen on 23/11/13.
//  Copyright (c) 2013 Greener Pastures. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDXMLElement;
@class EAGLESchematic;

@interface EAGLEObject : NSObject

@property (readonly, weak) EAGLESchematic *schematic;

- (id)initFromXMLElement:(DDXMLElement*)element;
- (id)initFromXMLElement:(DDXMLElement*)element inSchematic:(EAGLESchematic*)schematic;

@end

// Error macro
#if DEBUG
#define EAGLE_XML_PARSE_ERROR( error ) NSLog( @"Error parsing xml in -[%@ %@]: %@", NSStringFromClass( [self class] ), NSStringFromSelector( _cmd ), [error localizedDescription] )
#else
#define EAGLE_XML_PARSE_ERROR( error )
#endif

#if DEBUG
#define EAGLE_XML_PARSE_ERROR_RETURN_NIL( error ) if( error ) {NSLog( @"Error parsing xml in -[%@ %@]: %@", NSStringFromClass( [self class] ), NSStringFromSelector( _cmd ), [error localizedDescription] ); return nil; }
#else
#define EAGLE_XML_PARSE_ERROR_RETURN_NIL( error )
#endif
