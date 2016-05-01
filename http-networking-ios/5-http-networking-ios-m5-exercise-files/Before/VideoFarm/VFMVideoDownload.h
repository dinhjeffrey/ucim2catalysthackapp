//
//  VFMDownload.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/22/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VFMRemoteVideo;

/**
 * A persistent model object for tracking the download of a video's
 * thumbnail image and movie file.
 */
@interface VFMVideoDownload : NSObject <NSCoding>

@property (nonatomic, strong, readonly) VFMRemoteVideo *video;

@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong) NSNumber *totalMovieDownloadSize;
@property (nonatomic, strong) NSNumber *totalThumbnailDownloadSize;
@property (nonatomic, assign) NSUInteger movieRequestIdentifier;
@property (nonatomic, assign) NSUInteger thumbnailRequestIdentifier;

@property (nonatomic, strong) NSData *movieDownloadResumeData;
@property (nonatomic, strong) NSData *thumbnailDownloadResumeData;
@property (nonatomic, strong) NSError *movieDownloadError;
@property (nonatomic, strong) NSError *thumbnailDownloadError;
@property (nonatomic, assign, readonly) BOOL downloading;

/**
 * Designated initializer
 * @param video
 */
- (instancetype)initWithVideo:(VFMRemoteVideo *)video;

/**
 * Update the total number of bytes downloaded for the movie file.
 */
- (void)updateVideoContentProgress:(NSNumber *)progress;

/**
 * Update the total number of bytes downloaded for the thumbnail image file.
 */
- (void)updateThumbnailProgress:(NSNumber *)progress;

/**
 * The URL of the local movie file which may or may not yet exist.
 */
- (NSURL *)localMovieURL;

/**
 * The URL of the local thumbnail image file which may or may not yet exist.
 */
- (NSURL *)localThumbnailImageURL;

/**
 * Fetch all downloads that have been archived to disk.
 */
+ (NSArray *)allDownloads;

/**
 * Fetches and returns the download instance where the given request identifier
 * either matches the download's movie request identifier, or the thumbnail
 * image request identifier. Returns nil if no match is found.
 */
+ (VFMVideoDownload *)downloadForRequestIdentifier:(NSUInteger)requestIdentifier;

/**
 * Refreshes this download instance from persisted on-disk data
 */
- (void)refresh;

/**
 * Persist the current state of this download instance to disk
 */
- (BOOL)save;

/**
 * Delete the peristent state of this download
 */
- (BOOL)delete;

@end
