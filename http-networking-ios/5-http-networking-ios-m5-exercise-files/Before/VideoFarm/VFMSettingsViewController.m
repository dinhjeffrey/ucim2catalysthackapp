//
//  VFMSettingsViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/20/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMSettingsViewController.h"

#import "VFMAPIClient.h"

@interface VFMSettingsViewController () <UIAlertViewDelegate>

@end

@implementation VFMSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    VFMAPIClient *client = [VFMAPIClient sharedInstance];
    if (client) {
        self.endpointField.text = [client.endpointURL absoluteString];
    }
    
    [self.endpointField addTarget:self action:@selector(endpointFieldUpdated:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self == self.presentingViewController.presentedViewController) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observation

- (void)endpointFieldUpdated:(id)sender
{
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^http(s)?://.+"
                                                                            options:0
                                                                              error:nil];

    NSString *serverURL = self.endpointField.text;
    NSRange range = NSMakeRange(0, serverURL.length);
    BOOL serverReady = [regexp firstMatchInString:serverURL options:0 range:range] != nil;

    self.doneButton.enabled = serverReady;
}

#pragma mark - Actions

- (IBAction)didTapDone:(id)sender
{
    if ([VFMAPIClient sharedInstance]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                        message:@"Changing this setting will cancel any "
                              @"in-progress requests. Do you want to continue?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else {
        [VFMAPIClient setSharedInstanceEndpoint:[NSURL URLWithString:self.endpointField.text]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)didTapCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [VFMAPIClient setSharedInstanceEndpoint:[NSURL URLWithString:self.endpointField.text]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
