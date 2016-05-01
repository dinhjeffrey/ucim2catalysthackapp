//
//  VFMUploadCell.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/20/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMVideoProgressCell.h"

#import "VFMImageStore.h"
#import "VFMRemoteVideo.h"
#import "VFMVideo.h"
#import "VFMVideoDownload.h"
#import "VFMVideoUpload.h"

CGFloat VFMVideoProgressCellHeight = 60.0f;

@interface VFMVideoProgressCell ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *pauseResumeImage;

@end

@implementation VFMVideoProgressCell

- (void)dealloc
{
    self.upload = nil;
    self.download = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupContentView];
}

- (void)setupContentView
{
    self.imageView.clipsToBounds = YES;

    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.contentView addSubview:self.progressView];
    
    self.pauseResumeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pause-icon"]];
    [self.pauseResumeImage sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.frame = CGRectInset(CGRectMake(0, 0, VFMVideoProgressCellHeight, VFMVideoProgressCellHeight), 5, 5);
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
    textLabelFrame.origin.y = 0;
    textLabelFrame.size.height = 44;
    self.textLabel.frame = textLabelFrame;

    self.progressView.frame = CGRectMake(CGRectGetMinX(self.textLabel.frame),
                                         CGRectGetMaxY(self.textLabel.frame),
                                         CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.textLabel.frame) - 8,
                                         CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(self.textLabel.frame));
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.upload || object == self.download) &&
        [keyPath isEqualToString:@"progress"]) {
        self.progressView.progress = self.upload ? self.upload.progress : self.download.progress;
        if (self.progressView.progress == 1.0) {
            self.progressView.hidden = YES;
            if (self.download) {
                self.accessoryView = nil;
            }
        }
        else {
            self.progressView.hidden = NO;
            if (self.download) {
                self.accessoryView = self.pauseResumeImage;
            }
        }
    }
    else if (object == self.download && [keyPath isEqualToString:@"downloading"]) {
        UIImage *image = self.download.downloading ? [UIImage imageNamed:@"pause-icon"] : [UIImage imageNamed:@"resume-icon"];
        self.pauseResumeImage.image = image;
        [self.pauseResumeImage sizeToFit];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Properties

- (void)setUpload:(VFMVideoUpload *)upload
{
    if (_upload != upload) {
        self.download = nil;

        [_upload removeObserver:self forKeyPath:@"progress"];

        _upload = upload;
        
        [_upload addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
        
        self.accessoryView = nil;
        self.textLabel.text = upload.video.title;
        self.imageView.image = upload.thumbnailImage;
    }
}

- (void)setDownload:(VFMVideoDownload *)download
{
    if (_download != download) {
        self.upload = nil;
        
        [_download removeObserver:self forKeyPath:@"downloading"];
        [_download removeObserver:self forKeyPath:@"progress"];
        
        _download = download;
        
        [_download addObserver:self
                    forKeyPath:@"downloading"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];

        [_download addObserver:self forKeyPath:@"progress"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
        
        if (download.progress < 1.0) {
            self.accessoryView = self.pauseResumeImage;
        }
        else {
            self.accessoryView = nil;
        }

        self.textLabel.text = download.video.title;
        self.imageView.image = [self thumbnailImageFromDownload:download];
        
        if (download.downloading) {
            self.pauseResumeImage.image = [UIImage imageNamed:@"pause-icon"];
        }
        else {
            self.pauseResumeImage.image = [UIImage imageNamed:@"resume-icon"];
        }
        [self.pauseResumeImage sizeToFit];
        
        [self setNeedsLayout];
    }
}

- (void)setShowsPauseResumeButton:(BOOL)showsPauseResumeButton
{
    _showsPauseResumeButton = showsPauseResumeButton;
    if (showsPauseResumeButton) {
        self.accessoryView = self.pauseResumeImage;
    }
    else {
        self.accessoryView = nil;
    }
}

#pragma mark - Private helpers

- (UIImage *)thumbnailImageFromDownload:(VFMVideoDownload *)download
{
    NSURL *localThumbnailURL = [download localThumbnailImageURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbnailURL.path]) {
        NSData *data = [NSData dataWithContentsOfURL:localThumbnailURL];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:download.video.thumbnailImageURL];
        __weak typeof(self) weakSelf = self;
        UIImage *image = [[VFMImageStore sharedInstance] imageForURLRequest:request
                                                                placeholder:[UIImage imageNamed:@"video-icon"]
                                                                whenFetched:^(NSURLRequest *request, UIImage *image) {
                                                                    if ([request.URL isEqual:self.download.video.thumbnailImageURL]) {
                                                                        weakSelf.imageView.image = image;
                                                                        weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                        [weakSelf setNeedsLayout];
                                                                    }
                                                                }];
        
        return image;
    }
}

@end
