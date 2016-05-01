//
//  CCVSerializable.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/30/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCVSerializable <NSObject>

/**
 * Initialize a new instance based on the properties and structure
 * of the given dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Return a dictionary representing the data and structure of this
 * object. This is effectively the inverse of -initWithDictionary
 */
- (NSDictionary *)dictionaryRepresentation;

@end
