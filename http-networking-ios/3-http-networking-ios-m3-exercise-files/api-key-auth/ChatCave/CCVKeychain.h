//
//  CCVKeychain.h
//  ChatCave
//
//  Created by Alex Vollmer on 4/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A high-level abstraction over the hairy details of keychain access
 */
@interface CCVKeychain : NSObject

/**
 * Store a secret in the keychain for a specific key
 * @param secret The secret to store
 * @param key The key to associate with the secret
 * @param error "out" parameter describing error condition
 * @return BOOL if secret is stored successfully
 */
+ (BOOL)storeSecret:(NSData *)secret forKey:(NSString *)key error:(NSError **)error;

/**
 * Fetch a secret
 * @param key The key of the secret to fetch
 * @param error "Out" parameter describing error condition
 * @return NSData The secret associated with the key or nil if retrieval fails
 */
+ (NSData *)secretForKey:(NSString *)key error:(NSError **)error;

/**
 * Delete a secret
 * @param key The key for the secret to delete
 * @param error "Out" parameter if deletion fails
 * @param BOOL If key is successfully deleted
 */
+ (BOOL)deleteSecretForKey:(NSString *)key error:(NSError **)error;

@end
