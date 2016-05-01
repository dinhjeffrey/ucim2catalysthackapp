//
//  CCVChatroom.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatroom.h"

#import "CCVChatter.h"
#import "NSArray+Enumerable.h"

NSString * const CCVChatroomPublicIDKey = @"id";
NSString * const CCVChatroomNameKey = @"name";
NSString * const CCVChatroomChattersKey = @"chatters";

@interface CCVChatroom ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSArray *chatters;

@end

@implementation CCVChatroom

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name chatters:(NSArray *)chatters
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.name = name;
        self.chatters = chatters;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSArray *chattersFromDict = [dictionary[CCVChatroomChattersKey] mappedArrayWithBlock:^id(id obj) {
        return [[CCVChatter alloc] initWithDictionary:obj];
    }];

    return [self initWithPublicID:dictionary[CCVChatroomPublicIDKey]
                             name:dictionary[CCVChatroomNameKey]
                         chatters:chattersFromDict];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSArray *chatterDicts = [self.chatters mappedArrayWithBlock:^id(id obj) {
        return [(CCVChatter *)obj dictionaryRepresentation];
    }];

    return @{
        CCVChatroomPublicIDKey: self.publicID,
        CCVChatroomNameKey: self.name,
        CCVChatroomChattersKey: chatterDicts
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<0x%x %@ publicID=%@ name=%@>",
            (unsigned int)self,
            NSStringFromClass([self class]),
            self.publicID,
            self.name];
}

@end
