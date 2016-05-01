//
//  VFMAPIClient.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VFMRemoteVideo;
@class VFMVideoDownload;

/**
 * A notification posted when any upload progress occurs. The object
 * of the notification is a NSNumber wrapping the unique request
 * identifier (NSUInteger). The userInfo dictionary contains two keys:
 * VFMAPIClientUploadBytesUploaded and VFMAPIClientUploadTotalBytesToUpload.
 */
extern NSString * const VFMAPIClientUploadProgressNotification;

/**
 * A key to the userInfo dictionary for a VFMAPIClientUploadProgressNotification
 * which is a NSNumber instance reporting the total number of bytes uploaded
 * so far.
 */
extern NSString * const VFMAPIClientUploadBytesUploaded;

/**
 * A key to the userInfo dictionary for a VFMAPIClientUploadProgressNotification
 * which is a NSNumber instance reporting the total number of bytes to upload.
 */
extern NSString * const VFMAPIClientUploadTotalBytesToUpload;

/**
 * A notification posted when a background upload completes. The object
 * of the notification is a NSNumber wrapping the unique request identifier
 * (NSUInteger). The userInfo dictionary is empty.
 */
extern NSString * const VFMAPIClientBackgroundUploadCompletedNotification;

/**
 * A notification posted when a background upload fails. The object
 * of the notification is a NSNumber wrapping the unique request identifier
 * (NSUInteger). The userInfo dictionary contains a single object which
 * is the underlying error (using the VFMAPIClientBackgroundRequestFailedErrorKey)
 */
extern NSString * const VFMAPIClientBackgroundUploadFailedNotification;

/**
 * A notification post when a new background download is started. The object
 * of the notification is an instance of VFMVideoDownload. The userInfo
 * dictionary will be nil.
 */
extern NSString * const VFMAPIClientBackgroundDownloadStartedNotification;

/**
 * A notification posted when a background download completes successfully.
 * The object of the notification is a NSNumber wrapping the unique request
 * identifier (NSUInteger). The userInfo dictionary will be empty.
 */
extern NSString * const VFMAPIClientBackgroundDownloadCompletedNotification;

/**
 * A notification posted when a background download fails. The object
 * will be a NSNumber instance wrapping the unique request identifier
 * (NSUInteger). The userInfo dictionary contains a single object which
 * is the underlying error (using the VFMAPIClientBackgroundRequestFailedErrorKey)
 */
extern NSString * const VFMAPIClientBackgroundDownloadFailedNotification;

/**
 * A notification posted as a background download is processing. The
 * object of the notification is a NSNumber instance wrapping the unique
 * request identifier (NSUInteger). The userInfo dictionary contains two
 * keys: VFMAPIClientBackgroundBytesDownloaded and VFMAPIClientBackgroundTotalBytesToDownload
 */
extern NSString * const VFMAPIClientBackgroundDownloadProgressNotification;

/**
 * The userInfo key to a NSNumber indicating the number of bytes
 * downloaded so far.
 */
extern NSString * const VFMAPIClientBackgroundBytesDownloaded;

/**
 * The userInfo key to a NSNumber indicating the total number
 * of bytes to download.
 */
extern NSString * const VFMAPIClientBackgroundTotalBytesToDownload;

/**
 * The key to the userInfo dictionary for the VFMAPIClientBackgroundUploadFailedNotification
 * notification to get the underlying NSError instance
 */
extern NSString * const VFMAPIClientBackgroundRequestFailedErrorKey;

/**
 * A singleton class encapsulating network access to the underlying
 * VideoFarm server.
 */
@interface VFMAPIClient : NSObject

@property (nonatomic, strong, readonly) NSURL *endpointURL;

/**
 * Returns the single shared instance for this application. If the
 * +setSharedInstanceEndpoint: method has never been invoked, this
 * method will return nil.
 */
+ (instancetype)sharedInstance;

/**
 * Sets the shared instance (returned via +sharedInstance) to a new
 * instance with the given endpoint URL. The URL will be persisted
 * to user-defaults and will be used to attempt to automatically
 * recreate the +sharedInstance when the app is restarted.
 * NB: If the shared instance already has inflight tasks, they will
 * immediately be canceled and invalidated
 * @param endpointURL
 */
+ (void)setSharedInstanceEndpoint:(NSURL *)endpointURL;

/**
 * Cancels the request associated with the given unique identifier
 */
- (void)cancelRequestWithIdentifier:(NSUInteger)requestID;

/**
 * Fetch the list of videos available on the server.
 * @param success A callback block that receives an array of video model objects
 * @param failure A callback block that receives an NSError
 * @return NSUInteger identifier for the request.
 */
- (NSUInteger)fetchVideosSuccess:(void(^)(NSArray *videos))success
                         failure:(void(^)(NSError *error))failure;

/**
 * Prepares a new video data object on the server endpoint with the given parameters.
 * If successful, the `success` block will be invoked, otherwise the
 * `error` block is invoked.
 *
 * If the call is successful, you may follow up with a call to -uploadVideoFromURL:toPath:success:failure:
 * to upload the actual movie data file.
 * @param title (required)
 * @param thumbnail (required)
 * @param description (optional)
 * @param success
 * @param error
 * @return NSUInteger identifer for the request. Can be used for cancelation.
 */
- (NSUInteger)prepareVideoWithTitle:(NSString *)title
                          thumbnail:(UIImage *)thumbnail
                        description:(NSString *)description
                            success:(void(^)(NSString *))success
                            failure:(void(^)(NSError *))failure;

/**
 * Uploads the video file references by `sourceURL` to the video endpoint path
 * referred to by `path`. This upload occurs in the background so success,
 * upload progress and failure are all reported via notifications.
 * @param sourceURL
 * @param path In the form of '/videos/:video_id'
 */
- (NSUInteger)uploadVideoFromURL:(NSURL *)sourceURL
                          toPath:(NSString *)path;

/**
 * Download the associated movie and thumbnail image files from the given
 * VFMRemoteVideo. The downloading will be performed in the background even
 * when the app is offline.
 *
 * As soon as download request is made, a
 * VFMAPIClientBackgroundDownloadStartedNotification will be posted.
 *
 * Download progress can be monitored by listening for
 * VFMAPIClientBackgroundDownloadProgressNotification.
 *
 * If the download completes successfully a
 * VFMAPIClientBackgroundDownloadCompletedNotification will be posted, otherwise
 * the client will post a VFMAPIClientBackgroundDownloadFailedNotification.
 * @param video
 */
- (void)downloadMovieAndThumbnailForVideo:(VFMRemoteVideo *)video;

/**
 * Indicates whether or not a background task is currently running
 * that is downloading the associated movie file
 * @param video
 * @return BOOL
 */
- (BOOL)isDownloadingMovieFromVideo:(VFMRemoteVideo *)video;

/**
 * Indicates whether or not a background task is currently running
 * that is downloading the associated thumbnail image file
 * @param video
 * @return BOOL
 */
- (BOOL)isDownloadingThumbnailImageFromVideo:(VFMRemoteVideo *)video;

/**
 * Pause any outstanding downloads for the given VFMVideoDownload instance.
 * The underlying task will be canceled and the resumption data will be
 * persisted to the download.
 */
- (void)pauseDownloadsForVideo:(VFMVideoDownload *)download;

/**
 * Resume any previously-canceled downloads (via -pauseDownloadsForVideo:)
 * using the persisted resumption data in the given VFMVideoDownload instance.
 */
- (void)resumeDownloadsForVideo:(VFMVideoDownload *)download;

/**
 * When invoked, any response errors are temporarily accumulated and then
 * reported to the application delegate once the underlying background session's
 * -URLSessionDidFinishEventsForBackgroundURLSession: delegate method is
 * invoked.
 */
- (void)beginTrackingReponseErrors;

@end
