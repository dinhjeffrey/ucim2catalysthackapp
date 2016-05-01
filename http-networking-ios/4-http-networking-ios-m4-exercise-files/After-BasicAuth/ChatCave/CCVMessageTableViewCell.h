//
//  CCVMessageTableViewCell.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCVMessage;

extern CGFloat const CCVMessageTableViewCellHeight;

/**
 * A custom UITableViewCell for rendering messages for a chatroom
 */
@interface CCVMessageTableViewCell : UITableViewCell

/**
 * Setting this property causes the table cell to update its display
 * based on the information in the given message
 */
@property (nonatomic, strong) CCVMessage *message;

/**
 * Used to calculate the height of this table cell for its current 'message'
 */
- (CGFloat)currentRowHeight;

@end
