//
//  CCVChatroomMessagesViewController.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/2/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCVChatroom;

@interface CCVChatroomMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CCVChatroom *chatroom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *sendBoxView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendBoxViewBottomConstraint;

- (IBAction)sendMessage:(id)sender;
- (IBAction)didSwipeDown:(id)sender;

@end
