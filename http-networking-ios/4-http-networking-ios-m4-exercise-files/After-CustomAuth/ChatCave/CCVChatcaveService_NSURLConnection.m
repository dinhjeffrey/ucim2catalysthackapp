//
//  CCVChatcaveService_NSURLConnection.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/3/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatcaveService_NSURLConnection.h"

#import "CCVChatcaveService_SubclassMethods.h"
#import "CCVChatroom.h"
#import "CCVChatter.h"
#import "CCVMessage.h"
#import "CCVChatcaveService_NSURLConnectionRequest.h"
#import "NSArray+Enumerable.h"

@interface CCVChatcaveService_NSURLConnection () <CCVChatcaveService_NSURLConnectionRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestsPendingAuthentication;

@end

@implementation CCVChatcaveService_NSURLConnection

- (id)init
{
    if ((self = [super init]))
    {
        self.requestsPendingAuthentication = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Subclass methods

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(CCVChatcaveServiceSuccess)success
                           failure:(CCVChatcaveServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestForURL:URL method:httpMethod bodyDict:bodyDict];
    
    CCVChatcaveService_NSURLConnectionRequest *connectionRequest;
    connectionRequest = [[CCVChatcaveService_NSURLConnectionRequest alloc] initWithRequest:request
                                                                        expectedStatusCode:expectedStatus
                                                                                   success:success
                                                                                   failure:failure
                                                                                  delegate:self];
    
    NSString *connectionID = [connectionRequest uniqueIdentifier];
    [self.requests setObject:connectionRequest forKey:connectionID];
    return connectionID;
}

- (void)resendRequestsPendingAuthentication
{
    for (CCVChatcaveService_NSURLConnectionRequest *request in self.requestsPendingAuthentication) {
        [request restart];
    }
    
    [self.requestsPendingAuthentication removeAllObjects];
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
    CCVChatcaveService_NSURLConnectionRequest *request = [self.requests objectForKey:identifier];
    if (request) {
        [request cancel];
        [self.requests removeObjectForKey:identifier];
    }
}

#pragma mark - CCVChatcaveService_NSURLConnectionRequestDelegate

- (void)requestDidComplete:(CCVChatcaveService_NSURLConnectionRequest *)request
{
    [self.requests removeObjectForKey:[request uniqueIdentifier]];
    [self.requestsPendingAuthentication removeObject:request];
}

- (void)requestRequiresAuthentication:(CCVChatcaveService_NSURLConnectionRequest *)request
{
    [self.requestsPendingAuthentication addObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:CCVChatcaveServiceAuthRequiredNotification object:nil];
}

@end
