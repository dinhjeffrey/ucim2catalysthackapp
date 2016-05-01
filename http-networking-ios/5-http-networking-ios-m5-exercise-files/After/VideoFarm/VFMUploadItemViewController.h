//
//  VFMUploadViewController.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VFMVideoUpload;

@protocol VFMUploadItemViewControllerDelegate;

/**
 * The view-controller for capturing details for a new video to upload
 * to the VideoFarm server
 */
@interface VFMUploadItemViewController : UIViewController

@property (nonatomic, weak) id<VFMUploadItemViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIButton *chooseVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *recordVideoButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionArea;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIToolbar *descriptionAreaToolbar;

- (IBAction)didTapCancel:(id)sender;
- (IBAction)didTapDone:(id)sender;
- (IBAction)didTapChooseButton:(id)sender;
- (IBAction)didTapRecordButton:(id)sender;
- (IBAction)didTapDescriptionDone:(id)sender;

@end


@protocol VFMUploadItemViewControllerDelegate <NSObject>

- (void)uploadItemController:(VFMUploadItemViewController *)controller
           requestsUploadFor:(VFMVideoUpload *)upload;

@end