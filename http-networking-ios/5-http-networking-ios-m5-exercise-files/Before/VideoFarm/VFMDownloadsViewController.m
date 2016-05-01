//
//  VFMDownloadsViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/22/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import "VFMDownloadsViewController.h"

#import "VFMAPIClient.h"
#import "VFMRemoteVideo.h"
#import "VFMWatchVideoViewController.h"
#import "VFMVideo.h"
#import "VFMVideoDownload.h"
#import "VFMVideoProgressCell.h"

@interface VFMDownloadsViewController ()

@property (nonatomic, strong) NSMutableArray *downloads;

@end

@implementation VFMDownloadsViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = VFMVideoProgressCellHeight;
    [self fetchDownloads];
}

- (void)commonInit
{
    // common setup goes here
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
    return self.downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFMVideoProgressCell *cell = (VFMVideoProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
    cell.download = self.downloads[indexPath.row];
    
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
        VFMVideoDownload *download = self.downloads[indexPath.row];
        [download delete];

        [[VFMAPIClient sharedInstance] cancelRequestWithIdentifier:download.movieRequestIdentifier];
        [[VFMAPIClient sharedInstance] cancelRequestWithIdentifier:download.thumbnailRequestIdentifier];

        [tableView beginUpdates];
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.downloads removeObject:download];
        }
        [tableView endUpdates];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WatchVideo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        VFMVideoDownload *download = self.downloads[indexPath.row];
        
        VFMWatchVideoViewController *watchVC = (VFMWatchVideoViewController *)segue.destinationViewController;
        watchVC.download = download;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"WatchVideo"]) {
        VFMVideoProgressCell *cell = (VFMVideoProgressCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            VFMVideoDownload *download = self.downloads[indexPath.row];
            if (download.progress < 1.0) {
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Private helpers

- (void)fetchDownloads
{
    self.downloads = [NSMutableArray arrayWithArray:[VFMVideoDownload allDownloads]];
    [self.tableView reloadData];
}

- (VFMVideoDownload *)downloadMatchingTaskIdentifier:(NSUInteger)taskIdentifier
{
    NSUInteger downloadIndex = [self.downloads indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj movieRequestIdentifier] == taskIdentifier ||
            [obj thumbnailRequestIdentifier] == taskIdentifier) {
            *stop = YES;
            return YES;
        }
        else {
            return NO;
        }
    }];
    
    if (downloadIndex != NSNotFound) {
        return self.downloads[downloadIndex];
    }
    else {
        return nil;
    }
}

@end
