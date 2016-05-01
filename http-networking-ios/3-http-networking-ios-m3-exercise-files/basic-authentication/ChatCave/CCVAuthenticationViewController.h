//
//  CCVAuthenticationViewController.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/12/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCVAuthenticationViewControllerDelegate;

@interface CCVAuthenticationViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *serverURLField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *authenticationLabel;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (nonatomic, weak) id<CCVAuthenticationViewControllerDelegate> delegate;

- (IBAction)didTapSignIn:(id)sender;
- (IBAction)didTapSignUp:(id)sender;

@end

@protocol CCVAuthenticationViewControllerDelegate

- (void)authenticationViewControllerSucceeded:(CCVAuthenticationViewController *)authVC;

@end