//
//  VFMAppDelegate.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMAppDelegate.h"

#import "VFMAPIClient.h"
#import "VFMVideosViewController.h"

@interface VFMAppDelegate ()
@property (nonatomic, copy) void (^completionHandler)();
@end

@implementation VFMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor redColor];

    if ([VFMAPIClient sharedInstance] == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Settings"];
            [[self.window rootViewController] presentViewController:vc animated:YES completion:NULL];
        });
    }

    [application setMinimumBackgroundFetchInterval:30];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Background networking

- (void)application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    NSLog(@"%s identifier=%@", __PRETTY_FUNCTION__, identifier);
    
    self.completionHandler = completionHandler;
    
    // This will cause the VFMAPIClient to re-initialize and connect to the
    // background NSURLSession and handle the various delegate callbacks. It
    // will be responsible for invoking the stored completion handler once
    // all delegate callbacks have been delivered.
    [[VFMAPIClient sharedInstance] beginTrackingReponseErrors];
}

#pragma mark - Instance methods

- (void)invokeBackgroundTaskCompletionHandlerWithErrors:(NSArray *)errors
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.hasAction = NO;

        if (errors.count > 0) {
            notification.alertBody = @"One or more of your downloads failed";
        }
        else {
            notification.alertBody = @"Your downloads have completed";
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

        if (self.completionHandler != NULL) {
            self.completionHandler();
            self.completionHandler = NULL;
        }
    }];
}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"%s Fetching videos in the background...", __PRETTY_FUNCTION__);
    
    [[VFMAPIClient sharedInstance] fetchVideosSuccess:^(NSArray *videos) {
        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *navVC = (UINavigationController *)tabController.viewControllers[0];
        VFMVideosViewController *videosVC = (VFMVideosViewController *)navVC.topViewController;
        [videosVC updateVideos:videos];
        
        completionHandler(UIBackgroundFetchResultNewData);
    } failure:^(NSError *error) {
        NSLog(@"Unable to fetch /videos in background: %@", error);
        completionHandler(UIBackgroundFetchResultFailed);
    }];
}

@end
