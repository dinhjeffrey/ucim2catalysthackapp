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


@interface CCVChatter ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, copy, readwrite) NSString *name;

@end

@implementation CCVChatter

- (instancetype)initWithPublicID:(NSString *)publicID name:(NSString *)name
{
    if ((self = [super init])) {
        self.publicID = publicID;
        self.name = name;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    return [self initWithPublicID:dict[CCVChatterPublicIDKey]
                             name:dict[CCVChatterNameKey]];
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
