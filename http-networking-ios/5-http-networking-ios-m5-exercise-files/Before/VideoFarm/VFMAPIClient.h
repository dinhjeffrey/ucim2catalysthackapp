//
//  VFMAPIClient.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
