//
//  VFMAppDelegate.h
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 * Invokes the completion handler given to the application by the
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * method.
 * @param errors An array of NSError instances or nil (or empty) if there are none
 */
- (void)invokeBackgroundTaskCompletionHandlerWithErrors:(NSArray *)errors;

@end
