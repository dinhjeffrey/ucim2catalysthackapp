//
//  NSHTTPURLResponse+ChatcaveExtensions.h
//  ChatCave
//
//  Created by Alex Vollmer on 5/15/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (ChatcaveExtensions)

/**
 * Attempt to extract an error message from the given data object
 * (assumes JSON payload), otherwise return default error message.
 */
- (NSString *)errorMessageWithData:(NSData *)data;

@end
