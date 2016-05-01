//
//  VFMAPIClient.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMAPIClient.h"

#import "NSError+VideoFarmExtensions.h"
#import "NSURL+VFMLocalFile.h"
#import "VFMAPIRequest.h"
#import "VFMRemoteVideo.h"

static NSString * const VFMAPIEndpointURLKey = @"EndpointURL";
static NSString * const VFMAPIClientErrorDomain = @"VideoFarmErrorDomain";

@interface VFMAPIClient () <NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *tasksToRequests;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, strong, readwrite) NSURL *endpointURL;
@property (nonatomic, strong) NSURLSession *defaultSession;

@end

@implementation VFMAPIClient

- (instancetype)initWithEndpoint:(NSURL *)endpointURL
{
    if ((self = [super init])) {
        self.tasksToRequests = [NSMutableDictionary dictionary];
        self.tasks = [NSMutableDictionary dictionary];
        self.endpointURL = endpointURL;
        
        NSURLSessionConfiguration *sessionConf = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.defaultSession = [NSURLSession sessionWithConfiguration:sessionConf delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // Store last-used endpoint URL to user-defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:endpointURL.absoluteString forKey:VFMAPIEndpointURLKey];
        [defaults synchronize];
    }
    return self;
}

#pragma mark - Shared instance methods

static VFMAPIClient *SharedInstance;

+ (void)initialize
{
    NSString *endpointURLString = [[NSUserDefaults standardUserDefaults] objectForKey:VFMAPIEndpointURLKey];
    if (endpointURLString) {
        NSURL *endpointURL = [NSURL URLWithString:endpointURLString];
        SharedInstance = [[VFMAPIClient alloc] initWithEndpoint:endpointURL];
    }
}

+ (instancetype)sharedInstance
{
    return SharedInstance;
}

+ (void)setSharedInstanceEndpoint:(NSURL *)endpointURL
{
    if (SharedInstance) {
        [SharedInstance shutdown];
    }

    SharedInstance = [[VFMAPIClient alloc] initWithEndpoint:endpointURL];
}

#pragma mark - Public methods

- (void)cancelRequestWithIdentifier:(NSUInteger)requestID
{
    NSLog(@"%s canceling request with identifier: %lu", __PRETTY_FUNCTION__, (unsigned long)requestID);

    NSURLSessionTask *task = self.tasks[@(requestID)];
    [task cancel];
    [self.tasks removeObjectForKey:@(requestID)];
}

- (NSUInteger)fetchVideosSuccess:(void(^)(NSArray *videos))success
                         failure:(void(^)(NSError *error))failure
{
    NSURL *URL = [NSURL URLWithString:@"/videos" relativeToURL:self.endpointURL];
    
    NSLog(@"%s fetching videos from %@", __PRETTY_FUNCTION__, URL);

    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    [URLRequest setHTTPMethod:@"GET"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    void (^innerSuccess)(NSHTTPURLResponse *, NSData *) = ^(NSHTTPURLResponse *response, NSData *data) {
        NSError *error = nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (JSON) {
            if ([JSON isKindOfClass:[NSArray class]]) {
                NSMutableArray *videos = [NSMutableArray array];
                for (NSDictionary *dict in JSON) {
                    VFMRemoteVideo *video = [[VFMRemoteVideo alloc] initWithDictionary:dict];
                    [videos addObject:video];
                }
                
                success(videos);
            }
            else {
                NSDictionary *dict = @{NSLocalizedDescriptionKey: @"Invalid JSON response"};
                error = [NSError errorWithDomain:VFMAPIClientErrorDomain code:0 userInfo:dict];
                failure(error);
            }
        }
        else {
            failure(error);
        }
    };

    VFMAPIRequest *request = [[VFMAPIRequest alloc] initWithExpectedStatusCode:200
                                                                       success:innerSuccess
                                                                       failure:failure];
    
    NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithRequest:URLRequest];
    self.tasksToRequests[@(dataTask.taskIdentifier)] = request;
    self.tasks[@(dataTask.taskIdentifier)] = dataTask;
    [dataTask resume];
    
    return dataTask.taskIdentifier;
}

#pragma mark - Private Helpers

- (void)shutdown
{
    [self.defaultSession invalidateAndCancel];
    [self.tasksToRequests removeAllObjects];
    [self.tasks removeAllObjects];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"%s session %@ is now invalid: %@", __PRETTY_FUNCTION__, session.sessionDescription, error);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"%s %@ dataTask=%@ response=%@", __PRETTY_FUNCTION__,
          [NSString stringWithFormat:@"%@ %@", dataTask.originalRequest.HTTPMethod, dataTask.originalRequest.URL.path],
          dataTask, response);

    VFMAPIRequest *APIRequest = self.tasksToRequests[@(dataTask.taskIdentifier)];
    if (APIRequest) {
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        APIRequest.response = HTTPResponse;

        if (APIRequest.expectedStatusCode != HTTPResponse.statusCode) {
            completionHandler(NSURLSessionResponseCancel);
            
            NSDictionary *dict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unexpected HTTP status code: %li", (long)HTTPResponse.statusCode]};
            NSError *error = [NSError errorWithDomain:VFMAPIClientErrorDomain code:0 userInfo:dict];
            
            if (APIRequest.failure != NULL) {
                APIRequest.failure(error);
            }
            
            [self.tasksToRequests removeObjectForKey:@(dataTask.taskIdentifier)];
            [self.tasks removeObjectForKey:@(dataTask.taskIdentifier)];
            
            return;
        }
    }

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"%s %@ data=(%li bytes)", __PRETTY_FUNCTION__,
          [NSString stringWithFormat:@"%@ %@", dataTask.originalRequest.HTTPMethod, dataTask.originalRequest.URL.path],
          (unsigned long)data.length);
    VFMAPIRequest *APIRequest = self.tasksToRequests[@(dataTask.taskIdentifier)];
    if (APIRequest) {
        [APIRequest appendData:data];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([error isCancelationError]) {
        return;
    }

    VFMAPIRequest *APIRequest = self.tasksToRequests[@(task.taskIdentifier)];
    if (APIRequest) {
        if (error) {
            if (APIRequest.failure != NULL) {
                APIRequest.failure(error);
            }
        }
        else {
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)task.response;
            if (HTTPResponse.statusCode != APIRequest.expectedStatusCode) {
                NSDictionary *dict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unexpected HTTP status code: %li", (long)HTTPResponse.statusCode]};
                error = [NSError errorWithDomain:VFMAPIClientErrorDomain code:0 userInfo:dict];
                
                if (APIRequest.failure != NULL) {
                    APIRequest.failure(error);
                }
            }
            else if (APIRequest.success != NULL) {
                APIRequest.success(APIRequest.response, APIRequest.responseData);
            }
        }
    }

    [self.tasks removeObjectForKey:@(task.taskIdentifier)];
    [self.tasksToRequests removeObjectForKey:@(task.taskIdentifier)];

    NSLog(@"%s %@ error=%@", __PRETTY_FUNCTION__,
          [NSString stringWithFormat:@"%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.path],
          error);
}

@end
