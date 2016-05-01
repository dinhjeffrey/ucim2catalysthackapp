//
//  VFMSettingsViewController.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/20/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A view-controller for changing the server endpoint of the VideoFarm
 * for REST API access.
 */
@interface VFMSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *endpointField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)didTapDone:(id)sender;
- (IBAction)didTapCancel:(id)sender;

@end
