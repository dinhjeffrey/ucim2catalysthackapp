//
//  VFMVideoCell.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/21/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMVideoCell.h"

#import "VFMImageStore.h"
#import "VFMRemoteVideo.h"

CGFloat VFMVideoCellHeight = 60.0f;

@implementation VFMVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.imageView.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectInset(CGRectMake(0, 0, VFMVideoCellHeight, VFMVideoCellHeight), 5, 5);
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailLabelFrame = self.detailTextLabel.frame;
    detailLabelFrame.origin.x = CGRectGetMinX(textLabelFrame);
    self.detailTextLabel.frame = detailLabelFrame;
}

#pragma mark - Properties

- (void)setVideo:(VFMRemoteVideo *)video
{
    if (_video != video) {
        _video = video;
        
        self.textLabel.text = video.title;
        self.detailTextLabel.text = [NSString stringWithFormat:@"Uploaded %@ (%.2f s)",
                                     [[self class] stringFromDate:video.createdDate],
                                     self.video.duration];
        [self setThumbnailImageFromURL:video.thumbnailImageURL];
        
        [self setNeedsLayout];
    }
}

- (void)setThumbnailImageFromURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    UIImage *placeholder = [UIImage imageNamed:@"video-icon"];
    UIImage *image = [[VFMImageStore sharedInstance] imageForURLRequest:request
                                                            placeholder:placeholder
                                                            whenFetched:^(NSURLRequest *request, UIImage *image) {
                                                                if ([request.URL isEqual:self.video.thumbnailImageURL]) {
                                                                    self.imageView.image = image;
                                                                    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                }
                                                            }];
    
    self.imageView.image = image;
}

#pragma mark - Private helpers

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    });
    
    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self dateFormatter] dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    return [[self dateFormatter] stringFromDate:date];
}

@end
