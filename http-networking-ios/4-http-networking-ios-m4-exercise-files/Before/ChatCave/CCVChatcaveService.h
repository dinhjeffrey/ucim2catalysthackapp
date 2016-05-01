//
//  CCVChatcaveService.h
//  
//
//  Created by Alex Vollmer on 3/21/14.
//
//

#import <Foundation/Foundation.h>

@class CCVChatroom;
@class CCVChatter;

#import "CCVMessage.h"

/**
 * The notification name posted when an attempt has been made to retrieve
 * an authenticated resource and either no stored credentials were found,
 * or the current credentials are invalid.
 */
extern NSString * const CCVChatcaveServiceAuthRequiredNotification;

typedef void (^CCVChatcaveServiceSuccess)(NSData *data);

/**
 * The common callback block signature for remote calls that fail
 */
typedef void (^CCVChatcaveServiceFailure)(NSError *error);

/**
 * A base class defining a service that encapsulates access to the backend REST
 * server. All methods return immediately and the callback blocks are invoked
 * asynchronously (on the main thread) depending on success or failure of the operation
 *
 * Each operation returns a unique identifier for that operation that can later
 * be canceled with a call to -cancelRequestWithIdentifier:
 */
@interface CCVChatcaveService : NSObject

#pragma mark - Singleton access

+ (CCVChatcaveService *)sharedInstance;

#pragma mark - User Creation & Authentication

/**
 * Sign up as a new user for a given service
 * @param userName The screen handle for the new user
 * @param password The password for the new user
 * @param serverURL The URL for the service to add the user to. Note that this sets
 * the root URL for all subsequent requests for a CCVChatcaveService instance until
 * -signoutUserWithSuccess:failure: is invoked
 * @param success The callback block for a successful sign-up
 * @param failure The callback block for a failed sign-up attempt
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)registerNewUserWithName:(NSString *)userName
                             password:(NSString *)password
                            serverURL:(NSURL *)serverURL
                              success:(void(^)(CCVChatter *chatter))success
                              failure:(CCVChatcaveServiceFailure)failure;

/**
 * Sign in as an existing user for a given service
 * @param userName The screen handle for the user
 * @param password The password for the user
 * @param serverURL The URL for the service to authenticate with. Note that this sets
 * the root URL for all subsequent requests for a CCVChatcaveService instance until
 * -signoutUserWithSuccess:failure: is invoked
 * @param success The callback block for a successful sign-in
 * @param failure The callback block for a failed sign-in attempt
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)signInWithUserName:(NSString *)userName
                        password:(NSString *)password
                       serverURL:(NSURL *)serverURL
                         success:(void(^)(CCVChatter *chatter))success
                         failure:(CCVChatcaveServiceFailure)failure;

/**
 * Signs the user out of the current server URL endpoint specified in either the
 * -registerNewUserWithName:password:serverURL:success:failure or
 * -signInWithUserName:password:serverURL:success:failure. After this method is
 * invoked, the server URL endpoint is invalidated and invoking any API methods
 * other than signing-up or signing-in is not allowed.
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)signoutUserWithSuccess:(void(^)())success
                             failure:(CCVChatcaveServiceFailure)failure;

/**
 * Indicates if the user is currently signed-in with the service either via
 * sign-in or registration.
 */
- (BOOL)isUserSignedIn;

/**
 * Returns the currently signed-in user or nil of -isUserSignedIn returns NO
 */
- (CCVChatter *)currentUser;

/**
 * The current server this service instance is pointed at. This
 * method will be nil if -isUserSignedIn returns NO
 */
- (NSURL *)serverRoot;

#pragma mark - Chatrooms

/**
 * Fetch all chatrooms asynchronously. If successful, the 'success' block is invoked
 * otherwise the the 'failure' block is invoked
 * @param success The callback block for a successful fetch
 * @param failure The callback block for a failed fetch
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)fetchChatroomsSuccess:(void(^)(NSArray *chatrooms))success
                            failure:(CCVChatcaveServiceFailure)failure;

/**
 * Fetch a specific chatroom with the given public ID
 * @param chatroomID The public ID of the chatroom to fetch
 * @param success The callback block for a successful fetch
 * @param failure The callback block for a failed fetch
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)fetchChatroomWithID:(NSString *)chatroomID
                          success:(void(^)(CCVChatroom *chatroom))success
                          failure:(CCVChatcaveServiceFailure)failure;

/**
 * Create a new chatroom with the given name
 * @param name The name of the new chatroom
 * @param success The callback block if creation is successful
 * @param failure The callback block if creation fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)createChatroomWithName:(NSString *)name
                             success:(void(^)(CCVChatroom *chatroom))success
                             failure:(CCVChatcaveServiceFailure)failure;

/**
 * Delete a chatroom with the given ID
 * @param publicID The public identifier of the chatroom
 * @param success The callback block if deletion is successful
 * @param failure The callback block if deletion fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)deleteChatroomWithPublicID:(NSString *)publicID
                                 success:(void(^)())success
                                 failure:(CCVChatcaveServiceFailure)failure;

#pragma mark - Chatters

/**
 * Fetches the current chatters in a chatroom
 * @param chatroomID The unique of the chatroom to query
 * @param success The callback block if fetching succeeds. The block is passed
 * an NSArray of CCVChatter instances
 * @param failure The callback block if fetching fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)fetchChattersForChatroomID:(NSString *)chatroomID
                                 success:(void(^)(NSArray *chatters))success
                                 failure:(CCVChatcaveServiceFailure)failure;

/**
 * Adds the current user (matching -userIdentifier) to a chatroom
 * @param chatroomID The unique identifier of the chatroom to add to
 * @param success The callback block if the addition succeeds
 * @param failure The callback block if the addition fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)joinChatroomWithID:(NSString *)chatroomID
                         success:(void(^)())success
                         failure:(CCVChatcaveServiceFailure)failure;

/**
 * Removes a chatter from a chatroom
 * @param chatroomID The unique identifier of the chatroom to remove from
 * @param success The callback block if the removal succeeds
 * @param failure The callback block if the removal fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)leaveChatroomWithID:(NSString *)chatroomID
                          success:(void(^)())success
                          failure:(CCVChatcaveServiceFailure)failure;

#pragma mark - Messages

/**
 * Asynchronously fetches all messages for a given chatroom
 * @param chatroomID The public identifier of the chatroom to fetch messages from
 * @param success The callback block if fetching succeeds
 * @param failure The callback block if fetching fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                               success:(void(^)(NSArray *messages))success
                               failure:(CCVChatcaveServiceFailure)failure;

/**
 * Asynchronously fetches all message for a given chatroom submited
 * after the given sentinel message.
 * @param chatroomID The public identifier of the chatroom to fetch messages from
 * @param sentinelMessage The public identifier of the last known message on the client-side
 * @param success The callback block if fetching succeeds
 * @param failure The callback block if fetching fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                                 since:(NSString *)sentinelMessageID
                               success:(void(^)(NSArray *messages))success
                               failure:(CCVChatcaveServiceFailure)failure;

/**
 * Adds the given message to the given chatroom for the currentUser
 * @param text The text of the message
 * @param chatroomID The unique identifier of the chatroom
 * @param success The callback block if submission succeeds
 * @param failure The callback block if submission fails
 * @return A NSString identifier for the operation, suitable for canceling with
 * -cancelRequestWithIdentifier:
 */
- (NSString *)postMessageWithText:(NSString *)text
                       toChatroom:(NSString *)chatroomID
                          success:(void(^)(CCVMessage *message))success
                          failure:(CCVChatcaveServiceFailure)failure;

/**
 * Cancels the request matching the given identifier. If the operation has already
 * completed, the result is a no-op. If no matching operation can be found, the
 * result is a no-op.
 * @param identifier The ID of the request to cancel
 */
- (void)cancelRequestWithIdentifier:(NSString *)identifier;

@end

@interface CCVChatcaveService (SubclassRequirements)

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(CCVChatcaveServiceSuccess)success
                           failure:(CCVChatcaveServiceFailure)failure;

- (void)cancelRequestWithIdentifier:(NSString *)identifier;

- (void)resendRequestsPendingAuthentication;

@end