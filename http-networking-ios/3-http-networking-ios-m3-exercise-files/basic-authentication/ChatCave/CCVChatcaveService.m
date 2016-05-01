//
//  CCVChatcaveService.m
//  
//
//  Created by Alex Vollmer on 3/21/14.
//
//

#import "CCVChatcaveService.h"

#import "CCVChatroom.h"
#import "CCVChatter.h"
#import "NSArray+Enumerable.h"
#import "CCVChatcaveService_NSURLConnection.h"

NSString * const CCVChatcaveServiceAuthRequiredNotification = @"CCVChatcaveServiceAuthRequiredNotification";

/**
 * The user-defaults key for the URL of the last server the user authenticated
 * with
 */
static NSString * const CCVLastServerURLKey = @"LastServerURL";

/**
 * The user-defaults key for the user identifier
 */
static NSString * const CCVUserIdentifierKey = @"UserIdentifier";

/**
 * The user-defaults key for the current user
 */
static NSString * const CCVCurrentUserKey = @"CurrentUser";

static NSString * const CCVAuthorizationRealm = @"ChatCave Server";

static CCVChatcaveService *SharedInstance;

@interface CCVChatcaveService ()

@property (nonatomic, strong) CCVChatter *currentUser;
@property (nonatomic, strong) NSURL *tempServerRoot;
@property (nonatomic, strong) NSURL *serverRoot;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation CCVChatcaveService

+ (CCVChatcaveService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[CCVChatcaveService_NSURLConnection alloc] init];

        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];

        // clear any cookie caches
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
            [cookieStorage deleteCookie:cookie];
        }
    });
    
    return SharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.requests = [NSMutableDictionary dictionary];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serverRootString = [defaults stringForKey:CCVLastServerURLKey];
        if (serverRootString) {
            self.serverRoot = [NSURL URLWithString:serverRootString];
        }
        
        NSDictionary *userDict = [defaults objectForKey:CCVCurrentUserKey];
        if (userDict) {
            self.currentUser = [[CCVChatter alloc] initWithDictionary:userDict];
        }
    }
    return self;
}

#pragma mark - REST API methods

- (NSString *)signInWithUserName:(NSString *)userName
                        password:(NSString *)password
                       serverURL:(NSURL *)serverURL
                         success:(void (^)(CCVChatter *chatter))success
                         failure:(CCVChatcaveServiceFailure)failure
{
    self.tempServerRoot = serverURL;
    NSDictionary *params = @{
                             @"user[name]": userName,
                             @"user[password]": password
                             };
    
    return [self submitPUTPath:@"/account"
                          body:params
                expectedStatus:201
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (userDict && [userDict isKindOfClass:[NSDictionary class]]) {
                               self.currentUser = [[CCVChatter alloc] initWithDictionary:userDict];
                               self.tempServerRoot = nil;
                               self.serverRoot = serverURL;
                               
                               [self persistServerRootAndUserIdentifier];
                               [self persistCredentialsWithUserName:userName password:password];
                               
                               if (success != NULL) {
                                   success(self.currentUser);
                               }
                               
                               [self resendRequestsPendingAuthentication];
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:^(NSError *error) {
                           self.tempServerRoot = nil;
                           if (failure != NULL) {
                               failure(error);
                           }
                       }];
}

- (NSString *)registerNewUserWithName:(NSString *)userName
                             password:(NSString *)password
                            serverURL:(NSURL *)serverURL
                              success:(void (^)(CCVChatter *))success
                              failure:(CCVChatcaveServiceFailure)failure
{
    self.tempServerRoot = serverURL;
    
    NSDictionary *params = @{
                             @"user[name]": userName,
                             @"user[password]": password
                             };
    
    return [self submitPOSTPath:@"/users"
                           body:params
                 expectedStatus:201
                        success:^(NSData *data) {
                            self.tempServerRoot = nil;
                            NSError *error = nil;
                            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (userDict && [userDict isKindOfClass:[NSDictionary class]]) {
                                self.serverRoot = serverURL;
                                self.currentUser = [[CCVChatter alloc] initWithDictionary:userDict];

                                [self persistCredentialsWithUserName:userName password:password];
                                [self persistServerRootAndUserIdentifier];
                                
                                if (success != NULL) {
                                    success(self.currentUser);
                                }
                                
                                [self resendRequestsPendingAuthentication];
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:^(NSError *error) {
                            self.tempServerRoot = nil;
                            if (failure != NULL) {
                                failure(error);
                            }
                        }];
}

- (NSString *)signoutUserWithSuccess:(void (^)())success
                             failure:(CCVChatcaveServiceFailure)failure
{
    return [self submitDELETEPath:@"/account"
                          success:^(NSData *data) {
                              self.serverRoot = nil;
                              self.currentUser = nil;
                              
                              [self removePersistedCredentials];
                              [self persistServerRootAndUserIdentifier];
                              
                              if (success != NULL) {
                                  success();
                              }
                          }
                          failure:failure];
}

- (BOOL)isUserSignedIn
{
    return self.serverRoot != nil;
}

#pragma mark - Chatrooms

- (NSString *)fetchChatroomsSuccess:(void (^)(NSArray *))success
                            failure:(CCVChatcaveServiceFailure)failure
{
    return [self submitGETPath:@"/rooms"
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *chatrooms = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[CCVChatroom alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(chatrooms);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)fetchChatroomWithID:(NSString *)chatroomID
                          success:(void (^)(CCVChatroom *))success
                          failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", chatroomID];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:0
                                                                                  error:&error];
                           
                           if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                               CCVChatroom *chatroom = [[CCVChatroom alloc] initWithDictionary:dict];
                               
                               if (success != NULL) {
                                   success(chatroom);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)createChatroomWithName:(NSString *)name
                             success:(void (^)(CCVChatroom *))success
                             failure:(CCVChatcaveServiceFailure)failure
{
    return [self submitPOSTPath:@"/rooms"
                           body:@{ @"room[name]": name }
                 expectedStatus:201
                        success:^(NSData *data) {
                            NSError *error = nil;
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                CCVChatroom *chatroom = [[CCVChatroom alloc] initWithDictionary:dict];
                                
                                if (success != NULL) {
                                    success(chatroom);
                                }
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:failure];
}

- (NSString *)deleteChatroomWithPublicID:(NSString *)publicID
                                 success:(void (^)())success
                                 failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", publicID];
    return [self submitDELETEPath:path success:success failure:failure];
}

#pragma mark - Chatters

- (NSString *)fetchChattersForChatroomID:(NSString *)chatroomID
                                 success:(void (^)(NSArray *))success
                                 failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@", chatroomID];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           NSArray *chatters = results[@"chatters"];
                           if (chatters && [chatters isKindOfClass:[NSArray class]]) {
                               NSArray *mappedChatters = [chatters mappedArrayWithBlock:^id(id obj) {
                                   return [[CCVChatter alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(mappedChatters);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   NSError *error = [NSError errorWithDomain:@"com.pluralsight.ChatCave"
                                                                        code:0
                                                                    userInfo:@{NSLocalizedDescriptionKey: @"API returned invalid response"}];
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)joinChatroomWithID:(NSString *)chatroomID
                         success:(void (^)())success
                         failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/chatters/%@", chatroomID, self.currentUser.publicID];
    return [self submitPUTPath:path
                          body:nil
                expectedStatus:201
                       success:^(NSData *data) {
                           if (success != NULL) {
                               success();
                           }
                       }
                       failure:failure];
}

- (NSString *)leaveChatroomWithID:(NSString *)chatroomID
                          success:(void (^)())success
                          failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/chatters/%@", chatroomID, self.currentUser.publicID];
    return [self submitDELETEPath:path
                          success:^(NSData *data) {
                              if (success != NULL) {
                                  success();
                              }
                          }
                          failure:failure];
}

#pragma mark - Messages

- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                               success:(void (^)(NSArray *))success
                               failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", chatroomID];
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *messages = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[CCVMessage alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(messages);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)fetchMessagesForChatroom:(NSString *)chatroomID
                                 since:(NSString *)sentinelMessageID
                               success:(void (^)(NSArray *))success
                               failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages?since=%@",
                      chatroomID,
                      [sentinelMessageID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return [self submitGETPath:path
                       success:^(NSData *data) {
                           NSError *error = nil;
                           NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                           if (results && [results isKindOfClass:[NSArray class]]) {
                               NSArray *messages = [results mappedArrayWithBlock:^id(id obj) {
                                   return [[CCVMessage alloc] initWithDictionary:obj];
                               }];
                               
                               if (success != NULL) {
                                   success(messages);
                               }
                           }
                           else {
                               if (failure != NULL) {
                                   failure(error);
                               }
                           }
                       }
                       failure:failure];
}

- (NSString *)postMessageWithText:(NSString *)text
                       toChatroom:(NSString *)chatroomID
                          success:(void (^)(CCVMessage *))success
                          failure:(CCVChatcaveServiceFailure)failure
{
    NSString *path = [NSString stringWithFormat:@"/rooms/%@/messages", chatroomID];
    
    return [self submitPOSTPath:path
                           body:@{ @"message[text]": text }
                 expectedStatus:201
                        success:^(NSData *data) {
                            NSError *error = nil;
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                CCVMessage *message = [[CCVMessage alloc] initWithDictionary:dict];
                                
                                if (success != NULL) {
                                    success(message);
                                }
                            }
                            else {
                                if (failure != NULL) {
                                    failure(error);
                                }
                            }
                        }
                        failure:failure];
}

#pragma mark - Abstract methods

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(CCVChatcaveServiceSuccess)success
                           failure:(CCVChatcaveServiceFailure)failure
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
    return nil;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

- (void)resendRequestsPendingAuthentication
{
    NSAssert(NO, @"%s must be implemented in a sub-class!", __PRETTY_FUNCTION__);
}

#pragma mark - Request Helpers

- (void)persistServerRootAndUserIdentifier
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.serverRoot.absoluteString forKey:CCVLastServerURLKey];
    [defaults setObject:self.currentUser.publicID forKey:CCVUserIdentifierKey];
    [defaults setObject:[self.currentUser dictionaryRepresentation] forKey:CCVCurrentUserKey];
    [defaults synchronize];
}

- (NSURL *)URLWithPath:(NSString *)path
{
    NSURL *root = self.serverRoot ?: self.tempServerRoot;
    NSAssert(root != nil, @"Cannot make requests if neither serverRoot or tempServerRoot are nil");
    return [NSURL URLWithString:path relativeToURL:root];
}

- (NSString *)submitGETPath:(NSString *)path
                    success:(CCVChatcaveServiceSuccess)success
                    failure:(CCVChatcaveServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"GET"
                                 body:nil
                       expectedStatus:200
                              success:success
                              failure:failure];
}

- (NSString *)submitDELETEPath:(NSString *)path
                       success:(CCVChatcaveServiceSuccess)success
                       failure:(CCVChatcaveServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"DELETE"
                                 body:nil
                       expectedStatus:200
                              success:success
                              failure:failure];
}

- (NSString *)submitPOSTPath:(NSString *)path
                        body:(NSDictionary *)bodyDict
              expectedStatus:(NSInteger)expectedStatus
                     success:(CCVChatcaveServiceSuccess)success
                     failure:(CCVChatcaveServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"POST"
                                 body:bodyDict
                       expectedStatus:expectedStatus
                              success:success
                              failure:failure];
}

- (NSString *)submitPUTPath:(NSString *)path
                       body:(NSDictionary *)bodyDict
             expectedStatus:(NSInteger)expectedStatus
                    success:(CCVChatcaveServiceSuccess)success
                    failure:(CCVChatcaveServiceFailure)failure
{
    NSURL *URL = [self URLWithPath:path];
    return [self submitRequestWithURL:URL
                               method:@"PUT"
                                 body:bodyDict
                       expectedStatus:expectedStatus
                              success:success
                              failure:failure];
}

#pragma mark - Authentication

- (void)persistCredentialsWithUserName:(NSString *)userName password:(NSString *)password
{
    NSURLCredential *defaultCred = [NSURLCredential credentialWithUser:userName
                                                              password:password
                                                           persistence:NSURLCredentialPersistencePermanent];
    
    NSURLProtectionSpace *protectionSpace = [self protectionSpace];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:defaultCred forProtectionSpace:protectionSpace];
}

- (NSURLProtectionSpace *)protectionSpace
{
    return [[NSURLProtectionSpace alloc] initWithHost:self.serverRoot.host
                                                 port:self.serverRoot.port.intValue
                                             protocol:self.serverRoot.scheme
                                                realm:CCVAuthorizationRealm
                                 authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
}

- (void)removePersistedCredentials
{
    NSURLProtectionSpace *protectionSpace = [self protectionSpace];
    NSURLCredential *defaultCred = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (defaultCred) {
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:defaultCred forProtectionSpace:protectionSpace];
    }
}

@end
