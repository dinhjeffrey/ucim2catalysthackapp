//
//  CCVChatcaveService_SubclassMethods.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCVChatcaveService.h"

/**
 * A way for subclasses to "see" into the parent CCVChatcaveService class
 * without exposing all of the properties to the world. 
 */
@interface CCVChatcaveService (SubclassMethods)

@property (nonatomic, strong) NSURL *tempServerRoot;
@property (nonatomic, strong, readonly) NSMutableDictionary *requests;
@property (nonatomic, strong, readonly) NSMutableArray *requestsPendingAuthentication;

@end
