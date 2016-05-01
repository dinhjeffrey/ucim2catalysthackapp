//
//  CCVChatcaveService_NSURLConnectionRequest.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCVChatcaveService.h"

@protocol CCVChatcaveService_NSURLConnectionRequestDelegate;

/**
 * A class that wraps NSURLConnection for easier use and state-tracking
 */
@interface CCVChatcaveService_NSURLConnectionRequest : NSObject
<NSURLConnectionDelegate, NSURLConnectionDataDelegate>


/**
 * Initialize a new instance
 * @param request A NSURLRequest for the underlying connection to execute
 * @param statusCode The expected HTTP status code signaling successful execution
 * @param success The callback block to execute upon successful completion
 * @param failure The failure block to execute if the connection fails for any reason
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
             expectedStatusCode:(NSInteger)statusCode
                        success:(CCVChatcaveServiceSuccess)success
                        failure:(CCVChatcaveServiceFailure)failure
                       delegate:(id<CCVChatcaveService_NSURLConnectionRequestDelegate>)delegate;

/**
 * Cancel the underlying connection
 */
- (void)cancel;

/**
 * Restarts the request
 */
- (void)restart;

/**
 * The unique identifier for the request, used to track instances separately
 */
- (NSString *)uniqueIdentifier;

@end

@protocol CCVChatcaveService_NSURLConnectionRequestDelegate <NSObject>

- (void)requestDidComplete:(CCVChatcaveService_NSURLConnectionRequest *)request;

- (void)requestRequiresAuthentication:(CCVChatcaveService_NSURLConnectionRequest *)request;

@end


