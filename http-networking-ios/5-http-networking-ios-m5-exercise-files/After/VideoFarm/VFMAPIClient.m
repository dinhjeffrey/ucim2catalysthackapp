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
#import "VFMAppDelegate.h"
#import "VFMMultipartForm.h"
#import "VFMRemoteVideo.h"
#import "VFMVideoDownload.h"

NSString * const VFMAPIClientUploadProgressNotification = @"VFMAPIClientUploadProgressNotification";
NSString * const VFMAPIClientUploadBytesUploaded = @"VFMAPIClientUploadBytesUploaded";
NSString * const VFMAPIClientUploadTotalBytesToUpload = @"VFMAPIClientUploadTotalBytesToUpload";

NSString * const VFMAPIClientBackgroundUploadCompletedNotification = @"VFMAPIClientBackgroundUploadCompletedNotification";
NSString * const VFMAPIClientBackgroundUploadFailedNotification = @"VFMAPIClientBackgroundUploadFailedNotification";
NSString * const VFMAPIClientBackgroundRequestFailedErrorKey = @"VFMAPIClientBackgroundUploadFailedError";

NSString * const VFMAPIClientBackgroundDownloadStartedNotification = @"VFMAPIClientBackgroundDownloadStartedNotification";
NSString * const VFMAPIClientBackgroundDownloadCompletedNotification = @"VFMAPIClientBackgroundDownloadCompletedNotification";
NSString * const VFMAPIClientBackgroundDownloadFailedNotification = @"VFMAPIClientBackgroundDownloadFailedNotification";
NSString * const VFMAPIClientBackgroundDownloadProgressNotification = @"VFMAPIClientBackgroundDownloadProgressNotification";
NSString * const VFMAPIClientBackgroundBytesDownloaded = @"VFMAPIClientBackgroundBytesDownloaded";
NSString * const VFMAPIClientBackgroundTotalBytesToDownload = @"VFMAPIClientBackgroundTotalBytesToDownload";

static NSString * const VFMAPIEndpointURLKey = @"EndpointURL";
static NSString * const VFMAPIClientErrorDomain = @"VideoFarmErrorDomain";
static NSString * const VFMAPIClientBackgroundSessionIdentifier = @"VideoFarm Background Session";

static NSTimeInterval const VFMAPIVideoPrepareTimeout = 300;
static NSTimeInterval const VFMAPIVideoUploadTimeout = 600;

@interface VFMAPIClient () <NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *tasksToRequests;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@property (nonatomic, strong, readwrite) NSURL *endpointURL;
@property (nonatomic, strong) NSURLSession *defaultSession;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSMutableArray *responseErrors;

@end

@implementation VFMAPIClient

- (instancetype)initWithEndpoint:(NSURL *)endpointURL
{
    if ((self = [super init])) {
        self.tasksToRequests = [NSMutableDictionary dictionary];
        self.tasks = [NSMutableDictionary dictionary];
        self.endpointURL = endpointURL;

        NSURLSessionConfiguration *sessionConf = [NSURLSessionConfiguration backgroundSessionConfiguration:VFMAPIClientBackgroundSessionIdentifier];
        self.backgroundSession = [NSURLSession sessionWithConfiguration:sessionConf
                                                               delegate:self
                                                          delegateQueue:[NSOperationQueue mainQueue]];
        
        [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            for (NSURLSessionUploadTask *task in uploadTasks) {
                self.tasks[@(task.taskIdentifier)] = task;
            }
        }];
        
        sessionConf = [NSURLSessionConfiguration defaultSessionConfiguration];
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

- (NSUInteger)prepareVideoWithTitle:(NSString *)title
                          thumbnail:(UIImage *)thumbnail
                        description:(NSString *)description
                            success:(void (^)(NSString *))success
                            failure:(void (^)(NSError *))failure
{
    NSAssert(title != nil, @"Title must be non-nil");
    NSAssert(title.length > 0, @"Title must be non-zero length");
    NSAssert(thumbnail != nil, @"You must provide a thumbnail image");

    // Create the request
    NSURL *URL = [NSURL URLWithString:@"/videos" relativeToURL:self.endpointURL];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    [URLRequest setTimeoutInterval:VFMAPIVideoPrepareTimeout];
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Create the body
    VFMMultipartForm *multipart = [[VFMMultipartForm alloc] init];
    [multipart addFormValue:title forName:@"title"];
    [multipart addFormValue:description forName:@"description"];
    [multipart addPNGImage:thumbnail forName:@"thumbnail"];
    [URLRequest setHTTPBody:[multipart finalizedData]];
    [URLRequest setValue:[multipart contentType] forHTTPHeaderField:@"Content-Type"];
    
    void (^innerSuccess)(NSHTTPURLResponse *, NSData *) = ^(NSHTTPURLResponse *response, NSData *data) {
        if (success != NULL) {
            success([response allHeaderFields][@"Location"]);
        }
    };
    
    // Create the request
    VFMAPIRequest *request = [[VFMAPIRequest alloc] initWithExpectedStatusCode:303
                                                                       success:innerSuccess
                                                                       failure:failure];

    NSURLSessionUploadTask *task = [self.defaultSession uploadTaskWithRequest:URLRequest fromData:[multipart finalizedData]];
    self.tasksToRequests[@(task.taskIdentifier)] = request;
    self.tasks[@(task.taskIdentifier)] = task;
    [task resume];

    return task.taskIdentifier;
}

- (NSUInteger)uploadVideoFromURL:(NSURL *)sourceURL
                          toPath:(NSString *)path
{
    path = [path stringByAppendingPathComponent:@"movie"];
    NSURL *URL = [NSURL URLWithString:path relativeToURL:self.endpointURL];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    [URLRequest setTimeoutInterval:VFMAPIVideoUploadTimeout];
    [URLRequest setHTTPMethod:@"PUT"];
    [URLRequest setValue:@"movie/mp4" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionUploadTask *task = [self.backgroundSession uploadTaskWithRequest:URLRequest fromFile:sourceURL];
    self.tasks[@(task.taskIdentifier)] = task;
    [task resume];
    
    return task.taskIdentifier;
}

- (void)downloadMovieAndThumbnailForVideo:(VFMRemoteVideo *)video
{
    NSURLSessionDownloadTask *movieTask = [self.backgroundSession downloadTaskWithURL:video.movieURL];
    [movieTask resume];
    self.tasks[@(movieTask.taskIdentifier)] = movieTask;
    
    NSURLSessionDownloadTask *imageTask = [self.backgroundSession downloadTaskWithURL:video.thumbnailImageURL];
    [imageTask resume];
    self.tasks[@(imageTask.taskIdentifier)] = imageTask;
    
    VFMVideoDownload *download = [[VFMVideoDownload alloc] initWithVideo:video];
    download.movieRequestIdentifier = movieTask.taskIdentifier;
    download.thumbnailRequestIdentifier = imageTask.taskIdentifier;
    [download save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VFMAPIClientBackgroundDownloadStartedNotification
                                                        object:download];
}

- (BOOL)isDownloadingMovieFromVideo:(VFMRemoteVideo *)video
{
    for (NSURLSessionTask *task in self.tasks.allValues) {
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]] &&
            [task.originalRequest.URL isEqual:video.movieURL]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isDownloadingThumbnailImageFromVideo:(VFMRemoteVideo *)video
{
    for (NSURLSessionTask *task in self.tasks.allValues) {
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]] &&
            [task.originalRequest.URL isEqual:video.thumbnailImageURL]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)pauseDownloadsForVideo:(VFMVideoDownload *)download
{
    NSLog(@"%s pausing download %@", __PRETTY_FUNCTION__, download);

    // Cancel movie task with resume data
    NSURLSessionDownloadTask *movieTask = self.tasks[@(download.movieRequestIdentifier)];
    [movieTask cancelByProducingResumeData:^(NSData *resumeData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            download.movieDownloadResumeData = resumeData;
            download.movieRequestIdentifier = NSNotFound;
            [download save];
        });
    }];
    [self.tasks removeObjectForKey:@(movieTask.taskIdentifier)];
    
    // Cancel thumbnail task with resume data
    NSURLSessionDownloadTask *thumbnailTask = self.tasks[@(download.thumbnailRequestIdentifier)];
    [thumbnailTask cancelByProducingResumeData:^(NSData *resumeData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            download.thumbnailDownloadResumeData = resumeData;
            download.thumbnailRequestIdentifier = NSNotFound;
            [download save];
        });
    }];
    [self.tasks removeObjectForKey:@(thumbnailTask.taskIdentifier)];
}

- (void)resumeDownloadsForVideo:(VFMVideoDownload *)download
{
    NSLog(@"%s resuming download: %@", __PRETTY_FUNCTION__, download);

    if (download.movieDownloadResumeData) {
        NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithResumeData:download.movieDownloadResumeData];
        download.movieDownloadResumeData = nil;
        download.movieRequestIdentifier = task.taskIdentifier;
        self.tasks[@(task.taskIdentifier)] = task;
        [task resume];
    }
    
    if (download.thumbnailDownloadResumeData) {
        NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithResumeData:download.thumbnailDownloadResumeData];
        download.thumbnailDownloadResumeData = nil;
        download.thumbnailRequestIdentifier = task.taskIdentifier;
        self.tasks[@(task.taskIdentifier)] = task;
        [task resume];
    }
    
    [download save];
}

- (void)beginTrackingReponseErrors
{
    self.responseErrors = [NSMutableArray array];
}

#pragma mark - Private Helpers

- (void)shutdown
{
    [self.defaultSession invalidateAndCancel];
    [self.backgroundSession invalidateAndCancel];
    [self.tasksToRequests removeAllObjects];
    [self.tasks removeAllObjects];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"%s session %@ is now invalid: %@", __PRETTY_FUNCTION__, session.sessionDescription, error);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"%s session=%@", __PRETTY_FUNCTION__, session);

    VFMAppDelegate *appDelegate = (VFMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate invokeBackgroundTaskCompletionHandlerWithErrors:self.responseErrors];
    self.responseErrors = nil;
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

    // background tasks?
    if ([session.configuration.identifier isEqualToString:self.backgroundSession.configuration.identifier]) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if (error) {
            [self.responseErrors addObject:error];
            NSDictionary *dict = @{VFMAPIClientBackgroundRequestFailedErrorKey: error};

            if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {
                [nc postNotificationName:VFMAPIClientBackgroundUploadFailedNotification
                                  object:@(task.taskIdentifier)
                                userInfo:dict];
            }
            else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                VFMVideoDownload *download = [VFMVideoDownload downloadForRequestIdentifier:task.taskIdentifier];
                if (download.movieRequestIdentifier == task.taskIdentifier) {
                    download.movieDownloadError = error;
                }
                else if (download.thumbnailRequestIdentifier == task.taskIdentifier) {
                    download.thumbnailDownloadError = error;
                }
                [download save];

                [nc postNotificationName:VFMAPIClientBackgroundDownloadFailedNotification
                                  object:@(task.taskIdentifier)
                                userInfo:dict];
            }
        }
        else {
            if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {
                [nc postNotificationName:VFMAPIClientBackgroundUploadCompletedNotification
                                  object:@(task.taskIdentifier)
                                userInfo:nil];
            }
            else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                NSNumber *totalBytes = @(task.countOfBytesReceived);
                VFMVideoDownload *download = [VFMVideoDownload downloadForRequestIdentifier:task.taskIdentifier];
                if (download.movieRequestIdentifier == task.taskIdentifier) {
                    [download updateVideoContentProgress:totalBytes];
                    download.totalMovieDownloadSize = totalBytes;
                }
                else if (download.thumbnailRequestIdentifier == task.taskIdentifier) {
                    [download updateThumbnailProgress:totalBytes];
                    download.totalThumbnailDownloadSize = totalBytes;
                }
                [download save];

                [nc postNotificationName:VFMAPIClientBackgroundDownloadCompletedNotification
                                  object:@(task.taskIdentifier)];
            }
        }
    }
    // default sessions tasks (associated with VFMAPIRequest instance)
    else {
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
    }

    [self.tasks removeObjectForKey:@(task.taskIdentifier)];
    [self.tasksToRequests removeObjectForKey:@(task.taskIdentifier)];

    NSLog(@"%s %@ error=%@", __PRETTY_FUNCTION__,
          [NSString stringWithFormat:@"%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.path],
          error);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSURLRequest *request = task.originalRequest;
    NSString *resource = [NSString stringWithFormat:@"%@ %@", request.HTTPMethod, request.URL.path];

    NSLog(@"%s %@ (%lli/%lli/%lli)",
          __PRETTY_FUNCTION__,
          resource, bytesSent, totalBytesSent, totalBytesExpectedToSend);
    
    NSDictionary *userInfo = @{
        VFMAPIClientUploadBytesUploaded: @(totalBytesSent),
        VFMAPIClientUploadTotalBytesToUpload: @(totalBytesExpectedToSend)
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:VFMAPIClientUploadProgressNotification
                                                        object:@(task.taskIdentifier)
                                                      userInfo:userInfo];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__,
          [NSString stringWithFormat:@"%@ %@", task.originalRequest.HTTPMethod, task.originalRequest.URL.path]);

    VFMAPIRequest *APIRequest = self.tasksToRequests[@(task.taskIdentifier)];
    if (APIRequest) {
        if (! APIRequest.followRedirects) {
            completionHandler(NULL);
            return;
        }
    }
    
    completionHandler(request);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%s (%lli/%lli/%lli)", __PRETTY_FUNCTION__, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    NSDictionary *userInfo = @{
                               VFMAPIClientBackgroundBytesDownloaded: @(totalBytesWritten),
                               VFMAPIClientBackgroundTotalBytesToDownload: @(totalBytesExpectedToWrite)
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:VFMAPIClientBackgroundDownloadProgressNotification
                                                        object:@(downloadTask.taskIdentifier)
                                                      userInfo:userInfo];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *requestURL = downloadTask.originalRequest.URL;
    NSURL *videoURL = [requestURL localDownloadsFilesystemURL];
    
    if (videoURL) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSURL *videoParentURL = [videoURL URLByDeletingLastPathComponent];
        
        BOOL makeMove = NO;
        NSError *error = nil;
        if (! [fm fileExistsAtPath:videoParentURL.path]) {
            BOOL created = [fm createDirectoryAtPath:videoParentURL.path
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
            if (created) {
                makeMove = YES;
            }
            else {
                NSLog(@"%s ERROR failed to create directory %@: %@", __PRETTY_FUNCTION__, videoParentURL, error);
                return;
            }
        }
        else {
            makeMove = YES;
        }
        
        if (makeMove) {
            if ([fm moveItemAtURL:location toURL:videoURL error:&error]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VFMAPIClientBackgroundDownloadCompletedNotification
                                                                    object:@(downloadTask.taskIdentifier)];
            }
            else {
                NSLog(@"%s ERROR failed to move %@ to %@: %@", __PRETTY_FUNCTION__, location, videoURL, error);
            }
        }
    }
    else {
        NSLog(@"%s ERROR failed to locate downloads directory", __PRETTY_FUNCTION__);
    }
    
    [self.tasks removeObjectForKey:@(downloadTask.taskIdentifier)];
}

@end
