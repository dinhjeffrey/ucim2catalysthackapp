//
//  VFMUploadCell.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/20/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VFMVideoDownload;
@class VFMVideoUpload;

extern CGFloat VFMVideoProgressCellHeight;

/**
 * A UITableViewCell for displaying the progress of a video upload or 
 * download. Instances of this cell track the progress of an upload or
 * download using KVO.
 */
@interface VFMVideoProgressCell : UITableViewCell

@property (nonatomic, strong) VFMVideoUpload *upload;
@property (nonatomic, strong) VFMVideoDownload *download;
@property (nonatomic, assign) BOOL showsPauseResumeButton;

@end
