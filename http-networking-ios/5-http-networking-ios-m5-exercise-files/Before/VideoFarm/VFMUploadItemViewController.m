//
//  VFMUploadViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

#import "VFMUploadItemViewController.h"

#import "VFMVideo.h"
#import "VFMVideoUpload.h"

@interface VFMUploadItemViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation VFMUploadItemViewController

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [self.imageGenerator cancelAllCGImageGeneration];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - View lifecycle

- (void)configureChooseButton
{
    UIImageView *chooseIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose-icon"]];
    chooseIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chooseVideoButton addSubview:chooseIcon];
    
    self.chooseVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chooseVideoButton addConstraint:[NSLayoutConstraint constraintWithItem:chooseIcon
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.chooseVideoButton
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0]];
    [self.chooseVideoButton addConstraint:[NSLayoutConstraint constraintWithItem:chooseIcon
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.chooseVideoButton
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    
    self.chooseVideoButton.layer.cornerRadius = 5;
    self.chooseVideoButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.chooseVideoButton.layer.borderWidth = 3;
    self.chooseVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)configureRecordButton
{
    UIImageView *recordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-icon"]];
    recordIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.recordVideoButton addSubview:recordIcon];
    
    self.recordVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.recordVideoButton addConstraint:[NSLayoutConstraint constraintWithItem:recordIcon
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.recordVideoButton
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0]];
    [self.recordVideoButton addConstraint:[NSLayoutConstraint constraintWithItem:recordIcon
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.recordVideoButton
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];

    self.recordVideoButton.layer.cornerRadius = 5;
    self.recordVideoButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.recordVideoButton.layer.borderWidth = 3;
    self.recordVideoButton.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)configureDescriptionArea
{
    self.descriptionArea.layer.cornerRadius = 5;
    self.descriptionArea.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.descriptionArea.layer.borderWidth = 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.titleField addTarget:self action:@selector(checkStateForUpload) forControlEvents:UIControlEventAllEditingEvents];
    
    self.descriptionArea.inputAccessoryView = self.descriptionAreaToolbar;
    
    [self configureChooseButton];
    [self configureRecordButton];
    [self configureDescriptionArea];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Helpers

- (void)checkStateForUpload
{
    if (self.titleField.text.length > 1 && self.videoURL && self.thumbnailView.image) {
        self.doneButton.enabled = YES;
    }
    else {
        self.doneButton.enabled = NO;
    }
}

- (void)disableControls
{
    self.doneButton.enabled = NO;
    self.titleField.enabled = NO;
    [self.titleField resignFirstResponder];
    self.descriptionArea.editable = NO;
    [self.descriptionArea resignFirstResponder];
}

- (void)enableControls
{
    self.doneButton.enabled = YES;
    self.titleField.enabled = YES;
    self.descriptionArea.editable = YES;
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.descriptionArea isFirstResponder]) {
        NSNumber *animationCurve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        [UIView animateWithDuration:duration.doubleValue
                              delay:0
                            options:animationCurve.intValue << 16
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(keyboardFrame));
                         }
                         completion:NULL];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (! CGAffineTransformIsIdentity(self.view.transform)) {
        NSNumber *animationCurve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration.doubleValue
                              delay:0
                            options:animationCurve.intValue << 16
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:NULL];
    }
}

#pragma mark - Actions

- (IBAction)didTapCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)didTapDone:(id)sender
{
    [self disableControls];

    VFMVideo *video = [[VFMVideo alloc] initWithTitle:self.titleField.text
                                     videoDescription:self.descriptionArea.text];

    VFMVideoUpload *uploadItem = [[VFMVideoUpload alloc] initWithVideo:video
                                                         localVideoURL:self.videoURL
                                                        thumbnailImage:self.thumbnailView.image];

    [self.delegate uploadItemController:self requestsUploadFor:uploadItem];
}

- (IBAction)didTapChooseButton:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)didTapRecordButton:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)didTapDescriptionDone:(id)sender
{
    [self.descriptionArea resignFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.videoURL = info[UIImagePickerControllerMediaURL];
    
    AVAsset *videoAsset = [AVAsset assetWithURL:self.videoURL];
    
    if (self.imageGenerator) {
        [self.imageGenerator cancelAllCGImageGeneration];
    }
    
    [self.spinner startAnimating];
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    NSArray *times = @[[NSValue valueWithCMTime:CMTimeMake(1, 1)]];
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        
        if (image && result == AVAssetImageGeneratorSucceeded) {
            CGImageRetain(image);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbnailView.image = [UIImage imageWithCGImage:image];
                [self.spinner stopAnimating];
                [self checkStateForUpload];
                
                CGImageRelease(image);
            });
        }
        else {
            NSLog(@"ERROR: unable to generate images: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.chooseVideoButton.hidden = NO;
                self.recordVideoButton.hidden = NO;
            });
        }
    }];
    
    self.chooseVideoButton.hidden = YES;
    self.recordVideoButton.hidden = YES;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
