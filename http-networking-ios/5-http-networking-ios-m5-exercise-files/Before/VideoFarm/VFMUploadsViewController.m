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
            // TODO: cancel the preparation request (POST)
        }
        else if (upload.uploadRequestIdentifier != NSNotFound) {
            // TODO: cancel the movie upload request (PUT)
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
    // TODO: submit the movie file to the server
}

- (void)submitUpload:(VFMVideoUpload *)upload
{
    // TODO: submit the upload to the server
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
