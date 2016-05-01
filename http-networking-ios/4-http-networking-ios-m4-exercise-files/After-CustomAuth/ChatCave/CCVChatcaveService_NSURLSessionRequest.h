//
//  CCVChatcaveService_NSURLSessionRequest.h
//  ChatCave
//
//  Created by Alex Vollmer on 5/15/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCVChatcaveService.h"

@protocol CCVChatcaveService_NSURLSessionRequestDelegate;

/**
 * An instance of this class models a request encapsulated in a
 * NSURLSessionDataTask. It also tracks its unique identifier as well
 * as the expected HTTP status codes, and the appropriate dispatch blocks
 * for the success and failure cases.
 */
@interface CCVChatcaveService_NSURLSessionRequest : NSObject

@property (nonatomic, weak) id<CCVChatcaveService_NSURLSessionRequestDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, assign) NSInteger expectedStatus;
@property (nonatomic, copy) CCVChatcaveServiceSuccess successBlock;
@property (nonatomic, copy) CCVChatcaveServiceFailure failureBlock;

/**
 * Initialize a new instance which will immediately schedule the request. Delegate
 * methods will be invoked depending on the final response.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                   usingSession:(NSURLSession *)session
                 expectedStatus:(NSInteger)expectedStatus
                        success:(CCVChatcaveServiceSuccess)success
                        failure:(CCVChatcaveServiceFailure)failure
                       delegate:(id<CCVChatcaveService_NSURLSessionRequestDelegate>)delegate;

/**
 * Cancel this request.
 */
- (void)cancel;

/**
 * Restart this request. Delegate methods should be invoked depending on final response
 */
- (void)restart;

/**
 * The unique identifier of the request
 */
- (NSString *)requestIdentifier;

@end

@protocol CCVChatcaveService_NSURLSessionRequestDelegate <NSObject>

/**
 * Indicates that the request completed successfully with the response
 * returned the expected status code.
 */
- (void)sessionRequestDidComplete:(CCVChatcaveService_NSURLSessionRequest *)request;

/**
 * Indicates that the request failed for some reason, described in the given error
 */
- (void)sessionRequestFailed:(CCVChatcaveService_NSURLSessionRequest *)request error:(NSError *)error;

/**
 * Indicates that the request failed authentication (401 response) and requires
 * authentication before proceeding.
 */
- (void)sessionRequestRequiresAuthentication:(CCVChatcaveService_NSURLSessionRequest *)request;

@end