//
//  CCVKeychain.m
//  ChatCave
//
//  Created by Alex Vollmer on 4/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVKeychain.h"

static NSString * const CCVKeychainErrorDomain = @"ChatCave";
static NSString * const CCVKeychainSecService = @"ChatCave";

@implementation CCVKeychain

+ (BOOL)storeSecret:(NSData *)secret forKey:(NSString *)key error:(NSError **)error
{
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{
        (__bridge id)kSecClass: (__bridge  id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: CCVKeychainSecService,
        (__bridge id)kSecAttrAccount: key
    }];
    
    // check to see if we already have the secret
    if ([self secretForKey:key error:error]) {
        NSDictionary *attributes = @{ (__bridge id)kSecValueData: secret };
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query,
                                        (__bridge CFDictionaryRef)attributes);
        
        if (status == noErr) {
            return YES;
        }
        else if (*error == nil) {
            *error = [NSError errorWithDomain:CCVKeychainErrorDomain code:status userInfo:nil];
            return NO;
        }
    }
    // add new key
    else if (*error == nil) {
        query[(__bridge id)kSecValueData] = secret;

        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        
        if (status == noErr) {
            return YES;
        }
        else {
            *error = [NSError errorWithDomain:CCVKeychainErrorDomain code:status userInfo:nil];
            return NO;
        }
    }
    
    return NO;
}

+ (NSData *)secretForKey:(NSString *)key error:(NSError **)error
{
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge  id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: CCVKeychainSecService,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: (id)kCFBooleanTrue
    };
    
    CFTypeRef dataTypeRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
    
    if (status == noErr) {
        NSData *result = (__bridge NSData *)dataTypeRef;
        if (result) {
            return result;
        }
        else {
            if (error != nil) {
                *error = [NSError errorWithDomain:CCVKeychainErrorDomain code:1 userInfo:nil];
            }
        }
    }
    else {
        if (error != nil && status != errSecItemNotFound) {
            *error = [NSError errorWithDomain:CCVKeychainErrorDomain code:status userInfo:nil];
        }
    }

    return nil;
}

+ (BOOL)deleteSecretForKey:(NSString *)key error:(NSError **)error
{
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge  id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: CCVKeychainSecService,
                            (__bridge id)kSecAttrAccount: key,
                            (__bridge id)kSecReturnData: (id)kCFBooleanTrue
                            };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == noErr) {
        return YES;
    }
    else if (status == errSecItemNotFound) {
        return NO;
    }
    else {
        if (*error == nil) {
            *error = [NSError errorWithDomain:CCVKeychainErrorDomain code:status userInfo:nil];
        }
    }
    
    return NO;
}

@end
