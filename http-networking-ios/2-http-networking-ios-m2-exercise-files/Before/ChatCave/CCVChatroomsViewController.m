//
//  CCVChatroomsViewController.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/2/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatroomsViewController.h"

#import "CCVAppDelegate.h"
#import "CCVChatcaveService.h"
#import "CCVChatroom.h"
#import "CCVChatroomMessagesViewController.h"

@interface CCVChatroomsViewController ()

@property (nonatomic, strong) NSArray *chatrooms;

@end

@implementation CCVChatroomsViewController

#pragma mark - Properties

- (NSArray *)chatrooms
{
    if (_chatrooms == nil) {
        _chatrooms = [[NSArray alloc] init];
    }
    
    return _chatrooms;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.chatrooms count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];
    
    CCVChatroom *chatroom = self.chatrooms[indexPath.row];
    cell.textLabel.text = chatroom.name;
    
    NSUInteger chatterCount = [chatroom.chatters count];
    if (chatterCount == 1) {
        cell.detailTextLabel.text = @"1 chatter";
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu chatters", (unsigned long)chatterCount];
    }

    return cell;
}

#pragma mark - Segues

- (IBAction)unwindToChatroomsScene:(UIStoryboardSegue *)segue
{
    [self fetchChatrooms];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AuthenticationSegue"]) {
        CCVAuthenticationViewController *authVC = (CCVAuthenticationViewController *)segue.destinationViewController;
        authVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"JoinChatroom"]) {
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        CCVChatroom *chatroom = self.chatrooms[selectedPath.row];
        
        CCVChatroomMessagesViewController *vc = (CCVChatroomMessagesViewController *)segue.destinationViewController;
        vc.chatroom = chatroom;
    }
}

#pragma mark - Actions

- (void)didPullRefresh:(id)sender
{
    [self fetchChatrooms];
}

- (IBAction)didTapSignOut:(id)sender
{
    __weak typeof(self) weakSelf = self;
    CCVChatcaveService *service = [CCVChatcaveService sharedInstance];

    [service signoutUserWithSuccess:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CCVAuthenticationViewController *authVC = (CCVAuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationScene"];
        authVC.delegate = weakSelf;
        [weakSelf presentViewController:authVC animated:YES completion:NULL];
    }
                            failure:^(NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to sign out"
                                                                                message:error.localizedDescription
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                            }];
}

@end
