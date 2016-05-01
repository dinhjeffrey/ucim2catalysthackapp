//
//  NSURL+VFMLocalFile.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/24/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VFMLocalFile)

/**
 * Returns the local filesystem equivalent of this URL instances
 * for non-file schemes. Assuming a remote path like
 * http://someserver/videos/1234-abcd/movie.mov, this method will
 * return file:///~/Downloads/videos/1234-abcd/movie.mov. Otherwise
 * it simply returns `self`
 */
- (NSURL *)localDownloadsFilesystemURL;

@end
