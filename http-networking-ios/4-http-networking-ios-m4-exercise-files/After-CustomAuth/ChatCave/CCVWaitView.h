//
//  CCVWaitView.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/28/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A HUD-like modal wait spinner for blocking UI operations
 */
@interface CCVWaitView : UIView

/**
 * Display the wait view in center of the parent view with the 
 * given status text
 */
- (void)showWithText:(NSString *)text;

/**
 * Hide the wait view
 */
- (void)hide;

@end
