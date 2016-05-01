//
//  VFMAPIRequest.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A simple state-capturing object used by the VFMAPIClient for matching
 * various NSURLSessionTask to callback blocks (where applicable) and
 * determing what a successful response looks like.
 */
@interface VFMAPIRequest : NSObject

typedef void (^VFMAPIRequestSuccess)(NSHTTPURLResponse *response, NSData *data);
typedef void (^VFMAPIRequestFailure)(NSError *error);

@property (nonatomic, assign, readonly) NSUInteger expectedStatusCode;
@property (nonatomic, copy, readonly) VFMAPIRequestSuccess success;
@property (nonatomic, copy, readonly) VFMAPIRequestFailure failure;

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, assign) BOOL followRedirects;

/**
 * Designated initialized
 */
- (instancetype)initWithExpectedStatusCode:(NSUInteger)expectedStatusCode
                                   success:(VFMAPIRequestSuccess)success
                                   failure:(VFMAPIRequestFailure)failure;

/**
 * Calls to this method append to the final NSData object returned
 * via the `-responseData` method
 * @param data
 */
- (void)appendData:(NSData *)data;

/**
 * Returns all of the data accumulated via the `-appendData:` method
 * @return NSData
 */
- (NSData *)responseData;

@end
