//
//  NSURL+VFMLocalFile.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/24/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "NSURL+VFMLocalFile.h"

@implementation NSURL (VFMLocalFile)

- (NSURL *)localDownloadsFilesystemURL
{
    if ([self.scheme isEqualToString:@"file"]) {
        return self;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *downloadsDirURL = [fm URLForDirectory:NSDocumentDirectory
                                        inDomain:NSUserDomainMask
                               appropriateForURL:nil
                                          create:NO
                                           error:nil];
    return [downloadsDirURL URLByAppendingPathComponent:self.path];
}

@end
