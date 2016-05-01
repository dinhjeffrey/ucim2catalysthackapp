//
//  CCVChatcaveService_NSURLConnectionRequest.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatcaveService_NSURLConnectionRequest.h"

#import "NSHTTPURLResponse+ChatcaveExtensions.h"

@interface CCVChatcaveService_NSURLConnectionRequest ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) CCVChatcaveServiceSuccess successCallback;
@property (nonatomic, copy) CCVChatcaveServiceFailure failureCallback;
@property (nonatomic, assign) NSInteger expectedStatusCode;
@property (nonatomic, assign) NSInteger actualStatusCode;
@property (nonatomic, weak) id<CCVChatcaveService_NSURLConnectionRequestDelegate> delegate;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation CCVChatcaveService_NSURLConnectionRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
             expectedStatusCode:(NSInteger)statusCode
                        success:(CCVChatcaveServiceSuccess)success
                        failure:(CCVChatcaveServiceFailure)failure
                       delegate:(id<CCVChatcaveService_NSURLConnectionRequestDelegate>)delegate
{
    if ((self = [super init])) {
        self.request = request;
        self.expectedStatusCode = statusCode;
        self.successCallback = success;
        self.failureCallback = failure;
        self.uniqueIdentifier = [[NSUUID UUID] UUIDString];
        self.delegate = delegate;
        
        [self initiateRequest];
    }
    
    return self;
}

- (void)initiateRequest
{
    self.response = nil;
    self.data = [NSMutableData data];
    self.actualStatusCode = NSNotFound;
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

- (void)cancel
{
    [self.connection cancel];
}

- (void)restart
{
    [self cancel];
    [self initiateRequest];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSURLRequest *request = [connection originalRequest];
    
    [connection cancel];
    
    NSLog(@"%@ %@ %li FAIL %@", [request HTTPMethod], [request URL], (long)self.expectedStatusCode, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.failureCallback(error);
    });
    
    [self.delegate requestDidComplete:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    self.actualStatusCode = responseCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSURLRequest *request = [connection originalRequest];
    
    if ([self hasExpectedStatusCode]) {
        NSLog(@"%@ %@ %li SUCCESS", [request HTTPMethod], [request URL], (long)self.expectedStatusCode);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.successCallback(self.data);
        });
    }
    else if (self.actualStatusCode == 401) {
        [self.delegate requestRequiresAuthentication:self];
    }
    else {
        NSLog(@"%@ %@ %li INVALID STATUS CODE", [request HTTPMethod], [request URL], (long)self.actualStatusCode);
        
        NSString *message = [(NSHTTPURLResponse *)self.response errorMessageWithData:self.data];
        NSError *error = [NSError errorWithDomain:@"ChatcaveService"
                                             code:self.actualStatusCode
                                         userInfo:@{ NSLocalizedDescriptionKey: message }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.failureCallback(error);
        });
    }
    
    [self.delegate requestDidComplete:self];
}

#pragma mark - Private helpers

- (void)appendData:(NSData *)data
{
    [self.data appendData:data];
}

- (BOOL)hasExpectedStatusCode
{
    if (self.actualStatusCode != NSNotFound) {
        return self.expectedStatusCode == self.actualStatusCode;
    }
    
    return NO;
}

@end
