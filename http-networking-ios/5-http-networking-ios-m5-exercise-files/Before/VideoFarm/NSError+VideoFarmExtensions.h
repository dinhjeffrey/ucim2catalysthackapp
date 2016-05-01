//
//  NSError+VideoFarmExtensions.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/25/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (VideoFarmExtensions)

/**
 * Indicates if the underlying error represents an intentional cancelation
 * on the part of the user.
 * @return BOOL
 */
- (BOOL)isCancelationError;

@end
