//
//  CCVChatroomsViewController.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/2/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCVAuthenticationViewController.h"
#import "CCVCreateChatroomViewController.h"

/**
 * A view-controller that displays the currently-available chatrooms
 */
@interface CCVChatroomsViewController : UITableViewController <CCVAuthenticationViewControllerDelegate>

- (IBAction)didTapSignOut:(id)sender;

@end
