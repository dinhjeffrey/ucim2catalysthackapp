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

static NSString * const CCVChatcaveServiceAuthHeader = @"X-Magic-Auth";

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

- (NSString *)submitRequestWithURL:(NSURL *)URL
                            method:(NSString *)httpMethod
                              body:(NSDictionary *)bodyDict
                    expectedStatus:(NSInteger)expectedStatus
                           success:(CCVChatcaveServiceSuccess)success
                           failure:(CCVChatcaveServiceFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:httpMethod];
    
    // For now, assume body content is always form-urlencoded
    if (bodyDict) {
        [request setHTTPBody:[self formEncodedParameters:bodyDict]];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Set custom authentication header, if available
    if (self.currentUser.APIKey) {
        [request addValue:self.currentUser.APIKey forHTTPHeaderField:CCVChatcaveServiceAuthHeader];
    }
    
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
}

#pragma mark - Private helpers

- (NSData *)formEncodedParameters:(NSDictionary *)parameters
{
    NSArray *pairs = [parameters.allKeys mappedArrayWithBlock:^id(id obj) {
        return [NSString stringWithFormat:@"%@=%@",
                [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                [parameters[obj] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSString *formBody = [pairs componentsJoinedByString:@"&"];
    
    return [formBody dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Cancellation

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
