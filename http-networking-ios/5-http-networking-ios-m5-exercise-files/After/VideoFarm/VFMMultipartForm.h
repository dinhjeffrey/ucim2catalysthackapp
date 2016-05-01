//
//  VFMBodyData.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Represents a multi-part form for uploading data over HTTP.
 */
@interface VFMMultipartForm : NSObject

/**
 * Add a simple form name-value pair
 */
- (void)addFormValue:(NSString *)value forName:(NSString *)name;

/**
 * Add PNG image data
 */
- (void)addPNGImage:(UIImage *)image forName:(NSString *)name;

/**
 * Add JPEG image data
 */
- (void)addJPEGImage:(UIImage *)image forName:(NSString *)name;

/**
 * Add file data with the given content-type
 */
- (void)addFileAtURL:(NSURL *)URL
         contentType:(NSString *)contentType
            fileName:(NSString *)fileName
             forName:(NSString *)name;

/**
 * Returns multi-part encoded form data for use directly in HTTP requests
 */
- (NSData *)finalizedData;

/**
 * Returns an appropriate HTTP Content-Type header value that includes
 * the multipart boundary value
 */
- (NSString *)contentType;

@end
