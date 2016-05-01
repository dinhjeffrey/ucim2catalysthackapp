//
//  NSError+VideoFarmExtensions.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/25/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "NSError+VideoFarmExtensions.h"

@implementation NSError (VideoFarmExtensions)

- (BOOL)isCancelationError
{
    return [self.domain isEqualToString:NSURLErrorDomain] && self.code == NSURLErrorCancelled;
}

@end
