//
//  CCVMessageTableViewCell.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVMessageTableViewCell.h"

#import "CCVAppDelegate.h"
#import "CCVChatcaveService.h"
#import "CCVChatter.h"
#import "CCVMessage.h"

CGFloat const CCVMessageTableViewCellHeight = 135;

static CGFloat const kTextInset = 10;
static CGFloat const kIncomingBubbleLeftMargin = 16;
static CGFloat const kOutgoingLeftMargin = 106;
static CGFloat const kBubbleWidth = 204;
static CGFloat const kBubbleTopMargin = 10;

@interface CCVMessageTableViewCell ()

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *messageTextLabel;
@property (nonatomic, strong) UILabel *messageTimeLabel;
@property (nonatomic, strong) UILabel *messageAuthorLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CCVMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle __unused)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
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
    self.bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.bubbleView];

    self.messageTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    self.messageTextLabel.textColor = [UIColor whiteColor];
    self.messageTextLabel.numberOfLines = 0;
    self.messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageTextLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.messageTextLabel];
    
    self.messageTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.messageTimeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.messageTimeLabel];

    self.messageAuthorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageAuthorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.messageAuthorLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.messageAuthorLabel];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
}

#pragma mark - Layout

- (void)ccv_layoutSubviewsInternal
{
    // 1. Figure size of the message text
    NSDictionary *textAttrs = @{ NSFontAttributeName: self.messageTextLabel.font };
    CGRect textRect = [self.message.text boundingRectWithSize:CGSizeMake(kBubbleWidth, 10000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:textAttrs
                                                      context:nil];
    
    // 2. Figure out if this is incoming or outgoing
    CGFloat leftEdge = [self isIncomingMessage:self.message] ? kIncomingBubbleLeftMargin : kOutgoingLeftMargin;
    
    // 3. Size the messageTextLabel according to 1 & 2
    self.messageTextLabel.frame = CGRectMake(leftEdge + kTextInset,
                                             kBubbleTopMargin + kTextInset,
                                             kBubbleWidth - kTextInset - kTextInset,
                                             ceilf(textRect.size.height));
    
    // 4. Resize the background image according to 1 & 2
    self.bubbleView.frame = CGRectMake(leftEdge,
                                       kBubbleTopMargin,
                                       kBubbleWidth,
                                       self.messageTextLabel.frame.size.height + (2 * kTextInset));
    
    // 5. Lay the messageAuthorLabel out based on 4
    [self.messageAuthorLabel sizeToFit];
    self.messageAuthorLabel.frame = CGRectMake(leftEdge + kTextInset,
                                               CGRectGetMaxY(self.bubbleView.frame),
                                               CGRectGetWidth(self.messageAuthorLabel.frame),
                                               15);
    
    // 6. Lay the messageTimeLabel out based on 4
    [self.messageTimeLabel sizeToFit];
    self.messageTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.bubbleView.frame) - CGRectGetWidth(self.messageTimeLabel.frame) - kTextInset,
                                             CGRectGetMaxY(self.bubbleView.frame),
                                             CGRectGetWidth(self.messageTimeLabel.frame),
                                             15);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self ccv_layoutSubviewsInternal];
}

#pragma mark - Properties

- (void)setMessage:(CCVMessage *)message
{
    if (message != _message) {
        NSAssert(message.type == CCVMessageTypeChat,
                 @"%@ only supports messages of 'chat' type", NSStringFromClass([self class]));

        _message = message;
        
        NSString *imageName = ([self isIncomingMessage:message] ? @"incoming-box" : @"outgoing-box");
        self.bubbleView.image = [UIImage imageNamed:imageName];

        self.messageAuthorLabel.text = message.author;
        self.messageAuthorLabel.hidden = ! [self isIncomingMessage:message];
        self.messageTimeLabel.text = [self.dateFormatter stringFromDate:message.timestamp];

        NSString *messageText = message.text;
        if ((id)messageText == (id)[NSNull null]) {
            messageText = @"";
        }
        self.messageTextLabel.text = messageText;
        
        [self setNeedsLayout];
    }
}

#pragma mark - Public methods

- (CGFloat)currentRowHeight
{
    [self ccv_layoutSubviewsInternal];
    return CGRectGetMaxY(self.messageAuthorLabel.frame);
}

#pragma mark - Private Helpers

- (BOOL)isIncomingMessage:(CCVMessage *)message
{
    return ![message.author isEqualToString:[[CCVChatcaveService sharedInstance] currentUser].name];
}

@end
