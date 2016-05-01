//
//  CCVChatroom.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCVSerializable.h"

/**
 * The dictionary key for the publicID property
 */
extern NSString * const CCVChatroomPublicIDKey;

/**
 * The dictionary key for the name property
 */
extern NSString * const CCVChatroomNameKey;

/**
 * The dictionary key for the chatters property
 */
extern NSString * const CCVChatroomChattersKey;

/**
 * Represents a single chatroom
 */
@interface CCVChatroom : NSObject <CCVSerializable>

/**
 * The public ID used to communicate with the backend server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The user-facing public name of the chatroom
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The chatters in the chatroom
 */
@property (nonatomic, copy, readonly) NSArray *chatters;

/**
 * Initialize a new instance with the given public ID, name and chatters
 */
- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name chatters:(NSArray *)chatters;

/**
 * Initialize a new instance with a dictionary with keys matching
 * CCVChatroomPublicID and CCVChatroomName
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Returns a dictionary representation of this instance with
 * using the CCVChatroomPublicIDKey and CCVChatroomNameKey keys
 */
- (NSDictionary *)dictionaryRepresentation;

@end
