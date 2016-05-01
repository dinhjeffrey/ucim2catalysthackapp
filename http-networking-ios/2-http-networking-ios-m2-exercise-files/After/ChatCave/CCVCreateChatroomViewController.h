//
//  CCVCreateChatroomViewControllmer.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/2/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCVCreateChatroomViewControllerDelegate;

/**
 * A view-controller from which to add a new chatroom
 */
@interface CCVCreateChatroomViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *roomNameField;
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIView *waitView;

- (IBAction)didTapCreateRoom:(id)sender;

@end
