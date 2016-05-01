//
//  VFMUploadsViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/20/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMUploadsViewController.h"

#import "VFMAPIClient.h"
#import "VFMVideo.h"
#import "VFMVideoUpload.h"
#import "VFMVideoProgressCell.h"
#import "VFMUploadItemViewController.h"

@interface VFMUploadsViewController () <VFMUploadItemViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *uploads;

@end

@implementation VFMUploadsViewController

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:VFMAPIClientUploadProgressNotification object:nil];
    [nc removeObserver:self name:VFMAPIClientBackgroundUploadCompletedNotification object:nil];
    [nc removeObserver:self name:VFMAPIClientBackgroundUploadFailedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.uploads = [NSMutableArray arrayWithArray:[VFMVideoUpload allUploads]];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(uploadProgressed:)
               name:VFMAPIClientUploadProgressNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(backgroundUploadCompleted:)
               name:VFMAPIClientBackgroundUploadCompletedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(backgroundUploadFailed:)
               name:VFMAPIClientBackgroundUploadFailedNotification
             object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = VFMVideoProgressCellHeight;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.uploads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFMVideoProgressCell *cell = (VFMVideoProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"UploadCell" forIndexPath:indexPath];
    cell.upload = self.uploads[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        VFMVideoUpload *upload = self.uploads[indexPath.row];
        if (upload.preparationRequestIdentifier != NSNotFound) {
            [[VFMAPIClient sharedInstance] cancelRequestWithIdentifier:upload.preparationRequestIdentifier];
        }
        else if (upload.uploadRequestIdentifier != NSNotFound) {
            [[VFMAPIClient sharedInstance] cancelRequestWithIdentifier:upload.uploadRequestIdentifier];
        }

        [tableView beginUpdates];
        {
            [self.uploads removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [tableView endUpdates];
        
        [upload delete];
    }
}

#pragma mark - Notifications

- (void)backgroundUploadCompleted:(NSNotification *)notification
{
    NSUInteger requestID = [notification.object unsignedIntegerValue];
    NSLog(@"%s requestID=%lu", __PRETTY_FUNCTION__, (unsigned long)requestID);
    
    for (VFMVideoUpload *upload in self.uploads) {
        if (requestID == upload.uploadRequestIdentifier) {
            [upload delete];
            [self removeUpload:upload];
            break;
        }
    }
}

- (void)backgroundUploadFailed:(NSNotification *)notification
{
    NSUInteger requestID = [notification.object unsignedIntegerValue];
    NSLog(@"%s requestID=%lu", __PRETTY_FUNCTION__, (unsigned long)requestID);
    
    NSError *error = notification.userInfo[VFMAPIClientBackgroundRequestFailedErrorKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)uploadProgressed:(NSNotification *)notification
{
    NSUInteger taskIdentifier = [notification.object unsignedIntegerValue];

    for (VFMVideoUpload *upload in self.uploads) {
        if (upload.preparationRequestIdentifier == taskIdentifier || upload.uploadRequestIdentifier) {
            NSNumber *bytesSoFar = notification.userInfo[VFMAPIClientUploadBytesUploaded];
            
            if (taskIdentifier == upload.preparationRequestIdentifier) {
                [upload updateThumbnailImageProgress:bytesSoFar];
            }
            else {
                [upload updateVideoContentProgress:bytesSoFar];
            }
            
            break;
        }
    }
}

#pragma mark - Private helpers

- (void)removeUpload:(VFMVideoUpload *)upload
{
    [self.tableView beginUpdates];
    {
        NSUInteger index = [self.uploads indexOfObject:upload];
        if (index != NSNotFound) {
            [self.uploads removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView endUpdates];
}

#pragma mark - Networking

- (void)uploadVideo:(VFMVideoUpload *)upload toPath:(NSString *)path
{
    VFMAPIClient *client = [VFMAPIClient sharedInstance];
    NSUInteger requestID = [client uploadVideoFromURL:upload.localMovieURL
                                               toPath:path];
    
    upload.uploadRequestIdentifier = requestID;
    [upload save];
}

- (void)submitUpload:(VFMVideoUpload *)upload
{
    __weak typeof(self) weakSelf = self;
    
    VFMAPIClient *client = [VFMAPIClient sharedInstance];
    NSUInteger requestID = [client prepareVideoWithTitle:upload.video.title
                                               thumbnail:upload.thumbnailImage
                                             description:upload.video.videoDescription
                                                 success:^(NSString *path) {                                                                     [upload updateThumbnailImageProgress:upload.thumbnailImageSize];
                                                     upload.preparationRequestIdentifier = NSNotFound;
                                                     [upload save];
                                                     [weakSelf uploadVideo:upload toPath:path];
                                                 }
                                                 failure:^(NSError *error) {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preparation Error"
                                                                                                     message:error.localizedDescription
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                 }];
    
    upload.preparationRequestIdentifier = requestID;
    [upload save];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UploadItem"]) {
        UINavigationController *navVC = (UINavigationController *)segue.destinationViewController;
        VFMUploadItemViewController *itemVC = (VFMUploadItemViewController *)navVC.topViewController;
        itemVC.delegate = self;
    }
}

#pragma mark - VFMUploadItemViewControllerDelegate

- (void)uploadItemController:(VFMUploadItemViewController *)controller requestsUploadFor:(VFMVideoUpload *)upload
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView beginUpdates];
        {
            [self.uploads insertObject:upload atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationTop];
            
            [self submitUpload:upload];
        }
        [self.tableView endUpdates];
    }];
}

@end
