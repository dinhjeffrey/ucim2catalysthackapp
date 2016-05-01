//
//  CCVStatusMessageTableViewCell.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/24/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCVMessage;

/**
 * The proper height for one of these cells (fixed)
 */
extern CGFloat const CCVStatusMessageTableViewCellHeight;

/**
 * A table view cell for rendering a status message of type
 * "join" or "leave"
 */
@interface CCVStatusMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/**
 * Setting this property is ignored if the message isn't of type
 * CCVMessageTypeJoin or CCVMessageTypeLeave
 */
@property (nonatomic, strong) CCVMessage *message;

@end
