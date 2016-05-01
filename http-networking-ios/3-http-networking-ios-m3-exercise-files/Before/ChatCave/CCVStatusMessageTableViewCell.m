//
//  CCVStatusMessageTableViewCell.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/24/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVStatusMessageTableViewCell.h"

#import "CCVMessage.h"

CGFloat const CCVStatusMessageTableViewCellHeight = 20;

@implementation CCVStatusMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.textLabel.textColor = [UIColor darkGrayColor];
}

#pragma mark - Properties

- (void)setMessage:(CCVMessage *)message
{
    if (message != _message) {
        NSAssert(message.type == CCVMessageTypeJoin || message.type == CCVMessageTypeLeave,
                 @"Invalid message type: %i", message.type);
        
        _message = message;
        
        UIFont *lightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        UIFont *mediumFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        NSMutableAttributedString *statusStr = [[NSMutableAttributedString alloc] init];
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:message.author
                                                                      attributes:@{NSFontAttributeName:lightFont}];
        [statusStr appendAttributedString:nameStr];
        
        NSString *suffixStr = [NSString stringWithFormat:@" has %@", message.type == CCVMessageTypeLeave ? @"left" : @"joined"];
        [statusStr appendAttributedString:[[NSAttributedString alloc] initWithString:suffixStr
                                                                          attributes:@{NSFontAttributeName:mediumFont}]];
        
        self.statusLabel.attributedText = statusStr;
    }
}

@end
