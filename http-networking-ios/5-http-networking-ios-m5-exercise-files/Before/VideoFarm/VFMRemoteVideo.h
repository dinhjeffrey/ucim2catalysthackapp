//
//  VFMRemoteVideo.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VFMVideo.h"

/**
 * A model object representing videos available for viewing on the server
 */
@interface VFMRemoteVideo : VFMVideo

@property (nonatomic, copy, readonly) NSString *publicID;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSURL *thumbnailImageURL;
@property (nonatomic, strong, readonly) NSURL *movieURL;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong, readonly) NSDate *createdDate;

- (instancetype)initWithPublicID:(NSString *)publicID
                           title:(NSString *)title
                videoDescription:(NSString *)videoDescription
                             URL:(NSURL *)URL
               thumbnailImageURL:(NSURL *)thumbnailImageURL
                        movieURL:(NSURL *)movieURL
                        duration:(NSTimeInterval)duration
                     createdDate:(NSDate *)createdDate;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
