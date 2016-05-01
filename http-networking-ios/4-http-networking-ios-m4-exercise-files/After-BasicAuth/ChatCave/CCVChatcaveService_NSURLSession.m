//
//  CCVChatcaveService_NSURLSession.m
//  ChatCave
//
//  Created by Alex Vollmer on 5/15/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatcaveService_NSURLSession.h"

#import "CCVChatcaveService_NSURLSessionRequest.h"
#import "CCVChatcaveService_SubclassMethods.h"
#import "NSArray+Enumerable.h"

@interface CCVChatcaveService_NSURLSession () <CCVChatcaveService_NSURLSessionRequestDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation CCVChatcaveService_NSURLSession

- (id)init
{
    if ((self = [super init])) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        sessionConfig.HTTPCookieStorage = NULL;
        sessionConfig.HTTPShouldSetCookies = NO;
        sessionConfig.URLCredentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];

        self.requests = [NSMutableDictionary dictionary];
        self.requestsPendingAuthentication = [NSMutableArray array];
    }
    
    return self;
}

# pragma mark - Subclass methods


- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(CCVChatcaveServiceSuccess)success
                           failure:(CCVChatcaveServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestForURL:URL
                                                method:httpMethod
                                              bodyDict:bodyDict];

    CCVChatcaveService_NSURLSessionRequest *sessionRequest;
    sessionRequest = [[CCVChatcaveService_NSURLSessionRequest alloc] initWithRequest:request
                                                                        usingSession:self.session
                                                                      expectedStatus:expectedStatus
                                                                             success:success
                                                                             failure:failure
                                                                            delegate:self];
    
    self.requests[sessionRequest.requestIdentifier] = sessionRequest;
    return sessionRequest.requestIdentifier;
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    CCVChatcaveService_NSURLSessionRequest *request = self.requests[identifier];
    if (request) {
        [request cancel];
        [self.requests removeObjectForKey:identifier];
    }
}

- (void)resendRequestsPendingAuthentication
{
    for (CCVChatcaveService_NSURLSessionRequest *request in self.requestsPendingAuthentication) {
        [request restart];
    }
}

#pragma mark - CCVChatcaveService_NSURLSessionRequestDelegate

- (void)sessionRequestDidComplete:(CCVChatcaveService_NSURLSessionRequest *)request
{
    [self.requests removeObjectForKey:request.requestIdentifier];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestFailed:(CCVChatcaveService_NSURLSessionRequest *)request error:(NSError *)error
{
    [self.requests removeObjectForKey:request.requestIdentifier];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)sessionRequestRequiresAuthentication:(CCVChatcaveService_NSURLSessionRequest *)request
{
    [self.requestsPendingAuthentication addObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:CCVChatcaveServiceAuthRequiredNotification object:nil];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (challenge.previousFailureCount == 0) {
        NSURLProtectionSpace *space = [challenge protectionSpace];
        NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:space];
        if (credential) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            return;
        }
    }

    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CCVChatcaveServiceAuthRequiredNotification object:nil];

    for (CCVChatcaveService_NSURLSessionRequest *request in self.requests.allValues) {
        if (request.task.taskIdentifier == task.taskIdentifier) {
            [self.requestsPendingAuthentication addObject:request];
            break;
        }
    }
}

@end
