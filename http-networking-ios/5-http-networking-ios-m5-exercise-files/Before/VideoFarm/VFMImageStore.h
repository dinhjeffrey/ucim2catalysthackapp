//
//  VFMImageStore.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A write-through cache of network-fetched images
 */
@interface VFMImageStore : NSObject

/**
 * There can (or should) be only one
 */
+ (instancetype)sharedInstance;

/**
 * Return the UIImage from the given request. If a previous response is in
 * the cache, return that image, otherwise return the placeholder and issue
 * the request. The callback block is invoked after the network request
 * has completed.
 * @param request
 * @param placeholderImage
 * @param callback
 * @return UIImage
 */
- (UIImage *)imageForURLRequest:(NSURLRequest *)request
                    placeholder:(UIImage *)placeholderImage
                    whenFetched:(void(^)(NSURLRequest *request, UIImage *image))callback;

@end
