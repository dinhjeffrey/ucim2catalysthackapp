//
//  CCVMessage.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVMessage.h"

NSString * const CCVMessagePublicIDKey = @"id";
NSString * const CCVMessageTypeKey = @"type";
NSString * const CCVMessageTextKey = @"text";
NSString * const CCVMessageAuthorKey = @"author";
NSString * const CCVMessageTimestampKey = @"timestamp";

@interface CCVMessage ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, assign, readwrite) CCVMessageType type;
@property (nonatomic, strong, readwrite) NSDate *timestamp;

@end

@implementation CCVMessage

- (instancetype)initWithPublicID:(NSString *)publicID
                            type:(CCVMessageType)type
                            text:(NSString *)text
                          author:(NSString *)author
                       timestamp:(NSDate *)timestamp
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.type = type;
        self.text = text;
        self.author = author;
        self.timestamp = timestamp;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithPublicID:dictionary[CCVMessagePublicIDKey]
                             type:[self typeFromString:dictionary[CCVMessageTypeKey]]
                             text:dictionary[CCVMessageTextKey]
                           author:dictionary[CCVMessageAuthorKey]
                        timestamp:[[self class] dateFromString:dictionary[CCVMessageTimestampKey]]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
        CCVMessagePublicIDKey: self.publicID,
        CCVMessageTypeKey: @(self.type),
        CCVMessageAuthorKey: self.author,
        CCVMessageTextKey: self.text,
        CCVMessageTimestampKey: [[self class] stringFromDate:self.timestamp]
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x publicID=%@ text=%@ author=%@ type=%@ timestamp=%@>",
            NSStringFromClass([self class]),
            (unsigned int)self,
            self.publicID,
            self.text,
            self.author,
            [self typeAsString],
            self.timestamp];
}

- (NSString *)typeAsString
{
    if (self.type == CCVMessageTypeLeave) {
        return @"leave";
    }
    else if (self.type == CCVMessageTypeJoin) {
        return @"join";
    }
    else if (self.type == CCVMessageTypeChat) {
        return @"chat";
    }
    return @"unknown";
}

- (CCVMessageType)typeFromString:(NSString *)string
{
    if ([[string lowercaseString] isEqualToString:@"join"]) {
        return CCVMessageTypeJoin;
    }
    else if ([[string lowercaseString] isEqualToString:@"leave"]) {
        return CCVMessageTypeLeave;
    }
    else if ([[string lowercaseString] isEqualToString:@"chat"]) {
        return CCVMessageTypeChat;
    }
    return CCVMessageTypeUnknown;
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    });

    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self dateFormatter] dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    return [[self dateFormatter] stringFromDate:date];
}

@end
