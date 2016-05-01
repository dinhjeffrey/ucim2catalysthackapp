//
//  VFMMasterViewController.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A top-level view controller for fetching and displaying the list of
 * available videos from the VideoFarm server
 */
@interface VFMVideosViewController : UITableViewController

- (void)updateVideos:(NSArray *)videos;

@end
