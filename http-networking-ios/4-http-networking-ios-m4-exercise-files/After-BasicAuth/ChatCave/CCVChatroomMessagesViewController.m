//
//  CCVChatroomMessagesViewController.m
//  ChatCave
//
//  Created by Alex Vollmer on 3/2/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "CCVChatroomMessagesViewController.h"

#import "CCVAppDelegate.h"
#import "CCVChatcaveService.h"
#import "CCVChatroom.h"
#import "CCVMessage.h"
#import "CCVMessageTableViewCell.h"
#import "CCVStatusMessageTableViewCell.h"
#import "CCVWaitView.h"

static NSTimeInterval const kPollingInterval = 1.5;

@interface CCVChatroomMessagesViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) CCVWaitView *waitView;
@property (nonatomic, strong) NSMutableSet *requests;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) CCVMessageTableViewCell *messageSizingCell;
@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, assign) BOOL joinedChatroom;

@end

@implementation CCVChatroomMessagesViewController

#pragma mark - Lifecycle

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [self.pollingTimer invalidate];
    
    for (NSString *requestID in self.requests) {
        [[CCVChatcaveService sharedInstance] cancelRequestWithIdentifier:requestID];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.requests = [NSMutableSet set];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    }
    
    return self;
}

#pragma mark - Properties

- (NSMutableArray *)messages
{
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    
    return _messages;
}

- (void)setChatroom:(CCVChatroom *)chatroom
{
    if (chatroom != _chatroom) {
        _chatroom = chatroom;
        self.title = chatroom.name;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageSizingCell = [[CCVMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    self.waitView = [[CCVWaitView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.waitView];
    
    [self joinChatroom];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.messages.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCVMessage *message = self.messages[indexPath.row];

    if (message.type == CCVMessageTypeLeave || message.type == CCVMessageTypeJoin) {
        CCVStatusMessageTableViewCell *cell = (CCVStatusMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
        cell.message = message;
        return cell;
    }
    else {
        CCVMessageTableViewCell *cell = (CCVMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        cell.message = self.messages[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCVMessage *message = self.messages[indexPath.row];
    if (message.type == CCVMessageTypeJoin || message.type == CCVMessageTypeLeave) {
        return CCVStatusMessageTableViewCellHeight;
    }
    else {
        self.messageSizingCell.message = message;
        return [self.messageSizingCell currentRowHeight];
    }
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *animationDuration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    UITableViewCell *lastCell = [[self.tableView visibleCells] lastObject];

    [self.view layoutIfNeeded];
    [UIView animateKeyframesWithDuration:animationDuration.floatValue
                                   delay:0
                                 options:(animationCurve.intValue << 16)
                              animations:^{
                                  self.sendBoxViewBottomConstraint.constant = -CGRectGetHeight(keyboardRect);
                                  [self.tableView setContentOffset:CGPointMake(CGRectGetMinX(lastCell.frame),
                                                                               CGRectGetMaxY(lastCell.frame))];
                                  [self.view layoutIfNeeded];
                              }
                              completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *animationDuration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [self.view layoutIfNeeded];
    [UIView animateKeyframesWithDuration:animationDuration.floatValue
                                   delay:0
                                 options:(animationCurve.intValue << 16)
                              animations:^{
                                  self.sendBoxViewBottomConstraint.constant = 0;
                                  [self.view layoutIfNeeded];
                              }
                              completion:NULL];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.pollingTimer invalidate];
    self.pollingTimer = nil;

    if ([[segue identifier] isEqualToString:@"LeaveChatroom"] && self.joinedChatroom) {
        __weak typeof(self) weakSelf = self;
        CCVChatcaveService *service = [CCVChatcaveService sharedInstance];
        __block NSString *requestID = [service leaveChatroomWithID:self.chatroom.publicID
                                                           success:^{
                                                               [weakSelf.requests removeObject:requestID];
                                                           }
                                                           failure:^(NSError *error) {
                                                               [weakSelf.requests removeObject:requestID];
                                                               NSLog(@"Failed to leave chatroom: %@", error.localizedDescription);
                                                           }];
    }
}

#pragma mark - Private Helpers

- (void)joinChatroom
{
    if (! self.joinedChatroom) {
        [self.waitView showWithText:@"Joining Chatroom…"];

        __weak typeof(self) weakSelf = self;
        CCVChatcaveService *service = [CCVChatcaveService sharedInstance];
        __block NSString *requestID = [service joinChatroomWithID:self.chatroom.publicID
                                                          success:^{
                                                              [weakSelf.requests removeObject:requestID];
                                                              weakSelf.joinedChatroom = YES;
                                                              [weakSelf.waitView hide];
                                                              [weakSelf fetchMessages];
                                                              [weakSelf schedulePollingTimer];
                                                          }
                                                          failure:^(NSError *error) {
                                                              [weakSelf.requests removeObject:requestID];
                                                             
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to join chatroom"
                                                                                                              message:error.localizedDescription
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"OK"
                                                                                                    otherButtonTitles:nil];
                                                              [alert show];
                                                          }];
    }
}

- (void)fetchMessages
{
    if (self.isViewLoaded) {
        __weak typeof(self) weakSelf = self;
        __block NSString *requestID;
        
        void (^successCallback)(NSArray *) = ^(NSArray *newMessages) {
            [weakSelf.requests removeObject:requestID];
            if (newMessages.count) {
                [weakSelf appendMessages:newMessages];
            }
        };
        
        void (^failureCallback)(NSError *) = ^(NSError *error) {
            [weakSelf.requests removeObject:requestID];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        };
        
        if (self.messages.count > 0) {
            CCVMessage *lastMessage = [self.messages lastObject];
            requestID = [[CCVChatcaveService sharedInstance] fetchMessagesForChatroom:self.chatroom.publicID
                                                                                since:lastMessage.publicID
                                                                              success:successCallback
                                                                              failure:failureCallback];
        }
        else {
            requestID = [[CCVChatcaveService sharedInstance] fetchMessagesForChatroom:self.chatroom.publicID
                                                                              success:successCallback
                                                                              failure:failureCallback];
        }
    }
}

- (void)schedulePollingTimer
{
    if (self.pollingTimer == nil) {
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval
                                                             target:self
                                                           selector:@selector(fetchMessages)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)appendMessages:(NSArray *)newMessages
{
    NSUInteger previousMessageCount = self.messages.count;
    [self.tableView beginUpdates];
    {
        [self.messages addObjectsFromArray:newMessages];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = previousMessageCount; i < self.messages.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];

    // If we were (more or less) looking at the last cell, assume the user wants to scroll down
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:previousMessageCount - 1 inSection:0];
    if (previousMessageCount == 0 || [[self.tableView indexPathsForVisibleRows] containsObject:lastIndexPath]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)sendMessage:(id)sender
{
    __weak typeof(self) weakSelf = self;
    CCVChatcaveService *service = [CCVChatcaveService sharedInstance];
    __block NSString *requestID = [service postMessageWithText:self.messageField.text
                                                    toChatroom:self.chatroom.publicID
                                                       success:^(CCVMessage *message) {
                                                           [weakSelf.requests removeObject:requestID];
                                                       }
                                                       failure:^(NSError *error) {
                                                           [weakSelf.requests removeObject:requestID];
                                                           NSLog(@"ERROR: unable to post message: %@", error.localizedDescription);
                                                           // TODO: implement me!
                                                       }];
}

- (IBAction)didSwipeDown:(id)sender
{
    [self.messageField resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = textField.text.length > 0;
    if (shouldReturn) {
        [self sendMessage:nil];
        textField.text = nil;
        self.sendButton.enabled = NO;
    }
    return shouldReturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.sendButton.enabled = [finalText length] > 0;
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:@"LeaveChatroom" sender:nil];
}

@end
