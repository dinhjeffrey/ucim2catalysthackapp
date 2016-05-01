//
//  CCVMessage.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCVSerializable.h"

/**
 * The key for the publicID property
 */
extern NSString * const CCVMessagePublicIDKey;

/**
 * The key for the type property
 */
extern NSString * const CCVMessageTypeKey;

/**
 * The key for the text property
 */
extern NSString * const CCVMessageTextKey;

/**
 * The key for the author property
 */
extern NSString * const CCVMessageAuthorKey;

/**
 * The key for timestamp property
 */
extern NSString * const CCVMessageTimestampKey;

/**
 * The possible message types
 */
typedef enum {
    CCVMessageTypeUnknown = -1,
    CCVMessageTypeChat,
    CCVMessageTypeJoin,
    CCVMessageTypeLeave
} CCVMessageType;

/**
 * Represents a single message
 */
@interface CCVMessage : NSObject <CCVSerializable>

/**
 * The unique public ID used to communicate with the backend server
 */
@property (nonatomic, copy, readonly) NSString *publicID;

/**
 * The type of message
 */
@property (nonatomic, assign, readonly) CCVMessageType type;

/**
 * The text payload of the message
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * The user-facing display name of the author or related party
 * in the message
 */
@property (nonatomic, copy, readonly) NSString *author;

/**
 * The timestamp of the message
 */
@property (nonatomic, strong, readonly) NSDate *timestamp;

/**
 * Initialize a new instance with the given parameters
 */
- (instancetype)initWithPublicID:(NSString *)publicID
                            type:(CCVMessageType)type
                            text:(NSString *)text
                          author:(NSString *)author
                       timestamp:(NSDate *)date;

/**
 * Initialize a new instance with the values from the given
 * dictionary using the following keys:
 * - CCVMessagePublicIDKey (NSString)
 * - CCVMessageType (NSNumber)
 * - CCVMessageAuthorKey (NSString)
 * - CCVMessageTextKey (NSString)
 * - CCVMessageTimestampKey
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Returns a dictionary representation of this instance with
 * the following keys:
 * - CCVMessagePublicIDKey (NSString)
 * - CCVMessageType (NSNumber)
 * - CCVMessageAuthorKey (NSString)
 * - CCVMessageTextKey (NSString)
 * - CCVMessageTimestampKey
 */
- (NSDictionary *)dictionaryRepresentation;

@end
