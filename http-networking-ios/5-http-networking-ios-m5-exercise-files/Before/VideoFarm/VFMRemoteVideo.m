//
//  VFMRemoteVideo.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMRemoteVideo.h"

static NSString * const VFMVideoTitle = @"title";
static NSString * const VFMVideoPublicID = @"id";
static NSString * const VFMVideoVideoDescription = @"description";
static NSString * const VFMVideoURL = @"url";
static NSString * const VFMVideoImageURL = @"image";
static NSString * const VFMVideoMovieURL = @"movie";
static NSString * const VFMVideoDuration = @"duration";
static NSString * const VFMVideoCreatedDate = @"created";

@interface VFMRemoteVideo ()

@property (nonatomic, copy, readwrite) NSString *publicID;
@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, strong, readwrite) NSURL *thumbnailImageURL;
@property (nonatomic, strong, readwrite) NSURL *movieURL;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@property (nonatomic, strong, readwrite) NSDate *createdDate;

@end

@implementation VFMRemoteVideo

- (instancetype)initWithPublicID:(NSString *)publicID
                           title:(NSString *)title
                videoDescription:(NSString *)videoDescription
                             URL:(NSURL *)URL
               thumbnailImageURL:(NSURL *)thumbnailImageURL
                        movieURL:(NSURL *)movieURL
                        duration:(NSTimeInterval)duration
                     createdDate:(NSDate *)createdDate
{
    if ((self = [super initWithTitle:title videoDescription:videoDescription])) {
        self.publicID = publicID;
        self.URL = URL;
        self.thumbnailImageURL = thumbnailImageURL;
        self.movieURL = movieURL;
        self.duration = duration;
        self.createdDate = createdDate;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    return [self initWithPublicID:dict[VFMVideoPublicID]
                            title:dict[VFMVideoTitle]
                 videoDescription:dict[VFMVideoVideoDescription]
                              URL:[NSURL URLWithString:dict[VFMVideoURL]]
                thumbnailImageURL:[NSURL URLWithString:dict[VFMVideoImageURL]]
                         movieURL:[NSURL URLWithString:dict[VFMVideoMovieURL]]
                         duration:[dict[VFMVideoDuration] doubleValue]
                      createdDate:[[self class] dateFromString:dict[VFMVideoCreatedDate]]];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
        VFMVideoPublicID: self.publicID,
        VFMVideoTitle: self.title,
        VFMVideoVideoDescription: self.videoDescription,
        VFMVideoURL: self.URL.absoluteString,
        VFMVideoImageURL: self.thumbnailImageURL.absoluteString,
        VFMVideoMovieURL: self.movieURL.absoluteString,
        VFMVideoDuration: @(self.duration),
        VFMVideoCreatedDate: [[self class] stringFromDate:self.createdDate]
    };
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.publicID = [aDecoder decodeObjectForKey:VFMVideoPublicID];
    self.URL = [aDecoder decodeObjectForKey:VFMVideoURL];
    self.thumbnailImageURL = [aDecoder decodeObjectForKey:VFMVideoImageURL];
    self.movieURL = [aDecoder decodeObjectForKey:VFMVideoMovieURL];
    self.duration = [[aDecoder decodeObjectForKey:VFMVideoDuration] doubleValue];
    self.createdDate = [aDecoder decodeObjectForKey:VFMVideoCreatedDate];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.publicID forKey:VFMVideoPublicID];
    [aCoder encodeObject:self.URL forKey:VFMVideoURL];
    [aCoder encodeObject:self.thumbnailImageURL forKey:VFMVideoImageURL];
    [aCoder encodeObject:self.movieURL forKey:VFMVideoMovieURL];
    [aCoder encodeObject:@(self.duration) forKey:VFMVideoDuration];
    [aCoder encodeObject:self.createdDate forKey:VFMVideoCreatedDate];
}

#pragma mark - Date formatting

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    });
    
    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self dateFormatter] dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    return [[self dateFormatter] stringFromDate:date];
}

@end
