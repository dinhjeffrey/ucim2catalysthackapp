//
//  VFMDownload.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/22/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMVideoDownload.h"

#import "NSURL+VFMLocalFile.h"
#import "VFMRemoteVideo.h"

static NSString * const VFMVideoDownloadVideo = @"video";
static NSString * const VFMVideoDownloadMovieBytesDownloaded = @"movieBytesDownloaded";
static NSString * const VFMVideoDownloadTotalMovieDownloadSize = @"totalMovieSize";
static NSString * const VFMVideoDownloadThumbnailBytesDownloaded = @"thumbnailBytesDownloaded";
static NSString * const VFMVideoDownloadTotalThumbnailSize = @"totalThumbnailSize";
static NSString * const VFMVideoDownloadMovieRequestIdentifier = @"movieRequestIdentifier";
static NSString * const VFMVideoDownloadThumbnailRequestIdentifier = @"thumbnailRequestIdentifier";
static NSString * const VFMVideoDownloadMovieResumeData = @"movieResumeData";
static NSString * const VFMVideoDownloadThumbnailResumeData = @"thumbnailResumeData";
static NSString * const VFMVideoDownloadMovieError = @"movieDownloadError";
static NSString * const VFMVideoDownloadThumbnailError = @"thumbnailDownloadError";

@interface VFMVideoDownload ()

@property (nonatomic, strong, readwrite) VFMRemoteVideo *video;
@property (nonatomic, strong) NSNumber *movieBytesDownloaded;
@property (nonatomic, strong) NSNumber *thumbnailBytesDownloaded;
@property (nonatomic, strong) NSUUID *internalIdentifier;

@end

@implementation VFMVideoDownload

- (instancetype)initWithVideo:(VFMRemoteVideo *)video
{
    if ((self = [super init])) {
        self.video = video;
        self.movieRequestIdentifier = NSNotFound;
        self.thumbnailRequestIdentifier = NSNotFound;
        self.internalIdentifier = [NSUUID UUID];
        
        self.totalMovieDownloadSize = @(0);
        self.totalThumbnailDownloadSize = @(0);
        self.movieBytesDownloaded = @(0);
        self.thumbnailBytesDownloaded = @(0);
    }
    
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    VFMRemoteVideo *video = [aDecoder decodeObjectForKey:VFMVideoDownloadVideo];
    self = [self initWithVideo:video];

    self.movieBytesDownloaded = [aDecoder decodeObjectForKey:VFMVideoDownloadMovieBytesDownloaded];
    self.totalMovieDownloadSize = [aDecoder decodeObjectForKey:VFMVideoDownloadTotalMovieDownloadSize];
    self.thumbnailBytesDownloaded = [aDecoder decodeObjectForKey:VFMVideoDownloadThumbnailBytesDownloaded];
    self.totalThumbnailDownloadSize = [aDecoder decodeObjectForKey:VFMVideoDownloadTotalThumbnailSize];;
    
    self.movieRequestIdentifier = [[aDecoder decodeObjectForKey:VFMVideoDownloadMovieRequestIdentifier] unsignedIntegerValue];
    self.thumbnailRequestIdentifier = [[aDecoder decodeObjectForKey:VFMVideoDownloadThumbnailRequestIdentifier] unsignedIntegerValue];
    
    self.movieDownloadResumeData = [aDecoder decodeObjectForKey:VFMVideoDownloadMovieResumeData];
    self.thumbnailDownloadResumeData = [aDecoder decodeObjectForKey:VFMVideoDownloadThumbnailResumeData];
    
    self.movieDownloadError = [aDecoder decodeObjectForKey:VFMVideoDownloadMovieError];
    self.thumbnailDownloadError = [aDecoder decodeObjectForKey:VFMVideoDownloadThumbnailError];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.video forKey:VFMVideoDownloadVideo];
    [aCoder encodeObject:self.movieBytesDownloaded forKey:VFMVideoDownloadMovieBytesDownloaded];
    [aCoder encodeObject:self.totalMovieDownloadSize forKey:VFMVideoDownloadTotalMovieDownloadSize];
    [aCoder encodeObject:self.thumbnailBytesDownloaded forKey:VFMVideoDownloadThumbnailBytesDownloaded];
    [aCoder encodeObject:self.totalThumbnailDownloadSize forKey:VFMVideoDownloadTotalThumbnailSize];

    [aCoder encodeObject:@(self.movieRequestIdentifier) forKey:VFMVideoDownloadMovieRequestIdentifier];
    [aCoder encodeObject:@(self.thumbnailRequestIdentifier) forKey:VFMVideoDownloadThumbnailRequestIdentifier];
    
    [aCoder encodeObject:self.movieDownloadResumeData forKey:VFMVideoDownloadMovieResumeData];
    [aCoder encodeObject:self.thumbnailDownloadResumeData forKey:VFMVideoDownloadThumbnailResumeData];

    [aCoder encodeObject:self.movieDownloadError forKey:VFMVideoDownloadMovieError];
    [aCoder encodeObject:self.thumbnailDownloadError forKey:VFMVideoDownloadThumbnailError];
}

#pragma mark - Progress updates

- (void)updateVideoContentProgress:(NSNumber *)progress
{
    self.movieBytesDownloaded = progress;
}

- (void)updateThumbnailProgress:(NSNumber *)progress
{
    self.thumbnailBytesDownloaded = progress;
}

- (float)progress
{
    float soFar = [self.movieBytesDownloaded floatValue] + [self.thumbnailBytesDownloaded floatValue];
    float total = [self.totalMovieDownloadSize floatValue] + [self.totalThumbnailDownloadSize floatValue];
    
    if (total == 0) {
        return 0;
    }
    return soFar / total;
}

+ (NSSet *)keyPathsForValuesAffectingProgress
{
    return [NSSet setWithObjects:@"movieBytesDownloaded", @"totalMovieDownloadSize", @"thumbnailBytesDownloaded", @"totalThumbnailDownloadSize", nil];
}

- (NSURL *)localMovieURL
{
    return [self.video.movieURL localDownloadsFilesystemURL];
}

- (NSURL *)localThumbnailImageURL
{
    return [self.video.thumbnailImageURL localDownloadsFilesystemURL];
}

- (BOOL)downloading
{
    return ((self.movieDownloadResumeData == nil &&
             self.movieRequestIdentifier != NSNotFound) ||
            (self.thumbnailDownloadResumeData == nil &&
             self.thumbnailRequestIdentifier != NSNotFound));
}

+ (NSSet *)keyPathsForValuesAffectingDownloading
{
    return [NSSet setWithObjects:@"movieDownloadResumeData", @"movieRequestIdentifier", @"thumbnailDownloadResumeData", @"thumbnailRequestIdentifier", nil];
}

#pragma mark - Persistence

+ (NSArray *)allDownloads
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtURL:[self downloadDirectoryURL]
                       includingPropertiesForKeys:nil
                                          options:0
                                            error:&error];
    
    if (files) {
        NSMutableArray *downloads = [NSMutableArray arrayWithCapacity:files.count];
        for (NSURL *URL in files) {
            if ([URL.pathExtension isEqualToString:@"download"]) {
                VFMVideoDownload *download = [NSKeyedUnarchiver unarchiveObjectWithFile:URL.path];
                NSString *UUIDString = [[URL.path lastPathComponent] stringByDeletingPathExtension];
                download.internalIdentifier = [[NSUUID alloc] initWithUUIDString:UUIDString];
                [downloads addObject:download];
            }
        }
        
        return downloads;
    }
    else if (error) {
        NSLog(@"Unable to get contents for %@: %@", [self downloadDirectoryURL], error);
    }
    
    return [NSArray array];
}

+ (VFMVideoDownload *)downloadForRequestIdentifier:(NSUInteger)requestIdentifier
{
    for (VFMVideoDownload *download in [self allDownloads]) {
        if (requestIdentifier == download.movieRequestIdentifier ||
            requestIdentifier == download.thumbnailRequestIdentifier) {
            return download;
        }
    }
    
    return nil;
}

- (void)refresh
{
    NSData *data = [NSData dataWithContentsOfFile:[self archiveFileName]];
    if (data) {
        VFMVideoDownload *newDownload = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.totalMovieDownloadSize = newDownload.totalMovieDownloadSize;
        self.totalThumbnailDownloadSize = newDownload.totalThumbnailDownloadSize;
        self.movieRequestIdentifier = newDownload.movieRequestIdentifier;
        self.thumbnailRequestIdentifier = newDownload.thumbnailRequestIdentifier;
        self.movieDownloadResumeData = newDownload.movieDownloadResumeData;
        self.thumbnailDownloadResumeData = newDownload.thumbnailDownloadResumeData;
        self.movieBytesDownloaded = newDownload.movieBytesDownloaded;
        self.thumbnailBytesDownloaded = newDownload.thumbnailBytesDownloaded;
        self.movieDownloadError = newDownload.movieDownloadError;
        self.thumbnailDownloadError = newDownload.thumbnailDownloadError;
    }
}

- (BOOL)save
{
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:[self archiveFileName]];
    if (success) {
        NSLog(@"Saved upload: %@", self);
    }
    
    return success;
}

- (BOOL)delete
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL success = YES;
    
    // remove archive file
    NSError *error;
    if ([fm fileExistsAtPath:[self archiveFileName]]) {
        success = [fm removeItemAtPath:[self archiveFileName] error:&error];
        NSAssert(success, @"Failed to remove %@: %@", [self archiveFileName], error);
    }

    // remove movie file
    NSURL *movieFileURL = [self.video.movieURL localDownloadsFilesystemURL];
    if ([fm fileExistsAtPath:movieFileURL.path]) {
        success = [fm removeItemAtURL:movieFileURL error:&error];
        NSAssert(success, @"Failed to remove movie at %@: %@", movieFileURL, error);
    }
    
    // remove image file
    NSURL *imageFileURL = [self.video.thumbnailImageURL localDownloadsFilesystemURL];
    if ([fm fileExistsAtPath:imageFileURL.path]) {
        success = [fm removeItemAtURL:imageFileURL error:&error];
        NSAssert(success, @"Failed to remove thumbnail image at %@: %@", imageFileURL, error);
    }
    
    // nuke the parent directory (if empty)
    NSURL *parentDirURL = [movieFileURL URLByDeletingLastPathComponent];
    if ([fm fileExistsAtPath:parentDirURL.path]) {
        NSArray *children = [fm contentsOfDirectoryAtPath:parentDirURL.path
                                                    error:&error];
        NSAssert(children != nil, @"Unable to fetch contents of parent directory %@: %@", parentDirURL, error);
        if (children.count == 0) {
            success = [fm removeItemAtURL:parentDirURL error:&error];
            NSAssert(success, @"Unable to delete empty directory %@: %@", parentDirURL, error);
        }
    }

    NSLog(@"Removed upload: %@", self);
    return success;
}

+ (NSURL *)downloadDirectoryURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *docDirs = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSAssert(docDirs.count == 1, @"Found more than one Documents directory. What's up with that?");
    
    NSURL *docDir = [docDirs[0] URLByAppendingPathComponent:@"Downloads"];
    
    if (! [fm fileExistsAtPath:docDir.path]) {
        NSError *error = nil;
        BOOL success = [fm createDirectoryAtURL:docDir
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error];
        
        NSAssert(success, @"Failed to create directory %@: %@", docDir, error);
    }
    
    return docDir;
}

- (NSString *)archiveFileName
{
    NSURL *docURL = [[self class] downloadDirectoryURL];
    NSURL *archiveURL = [[docURL URLByAppendingPathComponent:[self.internalIdentifier UUIDString]] URLByAppendingPathExtension:@"download"];
    return [archiveURL path];
}

@end
