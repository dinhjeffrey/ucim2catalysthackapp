//
//  CCVChatter.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCVSerializable.h"

/**
 * A constant defining the JSON key to access the public ID of the chatter
 */
extern NSString * const CCVChatterPublicIDKey;

/**
 * A constant defining the JSON key to access the 'name' of the chatter
 */
extern NSString * const CCVChatterNameKey;

@interface CCVChatter : NSObject <CCVSerializable>

/**
 * The unique identifier of the chatter, used to communicate with the server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The name of the chatter
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The API key for the chatter
 */
@property (nonatomic, copy) NSString *APIKey;

/**
 * Create a new instance from constituent bits
 */
- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name APIKey:(NSString *)APIKey;

/**
 * Create a new instance from a dictionary using the CCVChatterPublicIDKey
 * and CCVChatterNameKey keys
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 * Returns a dictionary representation of a chatter suitable
 * for JSON serialization
 */
- (NSDictionary *)dictionaryRepresentation;

@end
