//
//  CCVChatter.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatter.h"

NSString * const CCVChatterPublicIDKey = @"id";
NSString * const CCVChatterNameKey = @"name";
NSString * const CCVChatterAPIKeyKey = @"apiKey";

@interface CCVChatter ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;

@end

@implementation CCVChatter

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name APIKey:(NSString *)APIKey
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.name = name;
        self.APIKey = APIKey;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    return [self initWithPublicID:dict[CCVChatterPublicIDKey]
                             name:dict[CCVChatterNameKey]
                           APIKey:dict[CCVChatterAPIKeyKey]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
        CCVChatterPublicIDKey: self.publicID,
        CCVChatterNameKey: self.name
     };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x publicID=%@ name=%@>",
            NSStringFromClass([self class]),
            (unsigned int)self,
            self.publicID,
            self.name];
}

@end
