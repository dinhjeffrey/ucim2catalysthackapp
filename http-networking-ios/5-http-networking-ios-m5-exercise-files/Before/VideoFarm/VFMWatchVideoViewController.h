//
//  VFMDetailViewController.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VFMRemoteVideo;
@class VFMVideoDownload;

/**
 * A view-controller for displaying the contents of a video's metadata
 * and a launching-point for playing back the underlying movie (streaming
 * or local).
 */
@interface VFMWatchVideoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadButton;

@property (nonatomic, strong) VFMRemoteVideo *video;
@property (nonatomic, strong) VFMVideoDownload *download;

- (IBAction)didTapThumbnail:(id)sender;
- (IBAction)didTapDownload:(id)sender;

@end
