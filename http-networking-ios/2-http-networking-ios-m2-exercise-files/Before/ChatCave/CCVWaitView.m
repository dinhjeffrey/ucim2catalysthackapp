//
//  CCVWaitView.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/28/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVWaitView.h"

@interface CCVWaitView ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation CCVWaitView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.hidden = YES;

        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.color = [UIColor purpleColor];
        [self addSubview:self.spinner];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.statusLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.statusLabel];
        
        // Layout constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.spinner
                                                         attribute:NSLayoutAttributeBaseline
                                                        multiplier:1
                                                          constant:5]];
    }
    return self;
}

#pragma mark - Public methods

- (void)showWithText:(NSString *)text
{
    self.statusLabel.text = text;
    [self.statusLabel sizeToFit];
    
    self.center = self.superview.center;
    
    [self.spinner startAnimating];

    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hide
{
    [self.spinner stopAnimating];

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

@end
