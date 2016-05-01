//
//  VFMVideoCell.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VFMRemoteVideo;

extern CGFloat VFMVideoCellHeight;

/**
 * A simple UITableViewCell extension for displaying VFMRemoteVideo instances
 */
@interface VFMVideoCell : UITableViewCell

@property (nonatomic, strong) VFMRemoteVideo *video;

@end
