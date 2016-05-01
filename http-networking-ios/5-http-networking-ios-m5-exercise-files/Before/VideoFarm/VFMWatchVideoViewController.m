//
//  VFMDetailViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>

#import "VFMWatchVideoViewController.h"

#import "NSURL+VFMLocalFile.h"
#import "VFMAPIClient.h"
#import "VFMImageStore.h"
#import "VFMRemoteVideo.h"
#import "VFMVideoDownload.h"

@implementation VFMWatchVideoViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureView];
}

- (void)configureView
{
    if (self.isViewLoaded) {
        self.titleLabel.text = self.video.title ?: self.download.video.title;
        self.descriptionView.text = self.video.videoDescription ?: self.download.video.videoDescription;

        // thumbnail image
        UIImage *thumbnailImage = nil;

        if (self.video) {
            thumbnailImage = [self imageFromURL:self.video.thumbnailImageURL];
        }
        else {
            NSData *thumbnailImageData = [NSData dataWithContentsOfURL:self.download.localThumbnailImageURL];
            if (thumbnailImageData) {
                thumbnailImage = [UIImage imageWithData:thumbnailImageData];
            }
            else {
                thumbnailImage = [self imageFromURL:self.download.video.thumbnailImageURL];
            }
        }
        [self.thumbnailButton setBackgroundImage:thumbnailImage forState:UIControlStateNormal];
        
        // TODO: check to see if we're already downloading this movie
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (void)setVideo:(VFMRemoteVideo *)video
{
    if (video != _video) {
        _video = video;
        
        [self configureView];
    }
}

- (void)setDownload:(VFMVideoDownload *)download
{
    if (download != _download) {
        _download = download;
        
        [self configureView];
    }
}

#pragma mark - Actions

- (IBAction)didTapThumbnail:(id)sender
{
    NSURL *movieURL = self.video.movieURL ?: self.download.localMovieURL;
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (IBAction)didTapDownload:(id)sender
{
    self.downloadButton.enabled = NO;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect imageFrame = [window convertRect:self.thumbnailButton.frame toWindow:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.thumbnailButton backgroundImageForState:UIControlStateNormal]];
    imageView.frame = imageFrame;
    [window addSubview:imageView];
    
    CGRect targetRect = CGRectMake(CGRectGetWidth(window.frame) - 50,
                                   CGRectGetHeight(window.frame) - 30,
                                   0,
                                   0);

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageView.frame = targetRect;
                         imageView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         // TODO: download the video's movie and thumbnail image
                         [imageView removeFromSuperview];
                     }];
}

#pragma mark - Private helpers

- (UIImage *)imageFromURL:(NSURL *)URL
{
    return [[VFMImageStore sharedInstance] imageForURLRequest:[NSURLRequest requestWithURL:URL]
                                                  placeholder:[UIImage imageNamed:@"video-icon"]
                                                  whenFetched:^(NSURLRequest *request, UIImage *image) {
                                                      [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
                                                  }];
}

@end
