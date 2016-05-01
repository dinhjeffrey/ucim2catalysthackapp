//
//  VFMDownloadsViewController.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/22/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A top-level view-controller for displaying and managing any downloaded
 * videos. New rows appear as a result of initiating downloads via the
 * VFMAPIClient. Downloads can also be paused, resumed, canceled and deleted
 * from this view-controller.
 */
@interface VFMDownloadsViewController : UITableViewController

@end
