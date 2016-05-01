//
//  VFMMasterViewController.m
//  VideoFarm
//
//  Created by Alex Vollmer on 5/19/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//
#import "VFMVideosViewController.h"

#import "VFMAPIClient.h"
#import "VFMRemoteVideo.h"
#import "VFMVideoCell.h"
#import "VFMWatchVideoViewController.h"

@interface VFMVideosViewController ()

@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, assign) NSUInteger requestIdentifier;

@end

@implementation VFMVideosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = VFMVideoCellHeight;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(didPullRefresh:) forControlEvents:UIControlEventValueChanged];

    self.requestIdentifier = NSNotFound;
    [self fetchVideos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Networking

- (void)fetchVideos
{
    if (! self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    if (self.requestIdentifier != NSNotFound) {
        [[VFMAPIClient sharedInstance] cancelRequestWithIdentifier:self.requestIdentifier];
        self.requestIdentifier = NSNotFound;
    }
    
    __weak typeof(self) weakSelf = self;
    self.requestIdentifier = [[VFMAPIClient sharedInstance] fetchVideosSuccess:^(NSArray *videos) {
        weakSelf.videos = videos;
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
        weakSelf.requestIdentifier = NSNotFound;
    } failure:^(NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        weakSelf.requestIdentifier = NSNotFound;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - Public methods

- (void)updateVideos:(NSArray *)videos
{
    self.videos = videos;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)didPullRefresh:(id)sender
{
    [self fetchVideos];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFMVideoCell *cell = (VFMVideoCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
    VFMRemoteVideo *video = self.videos[indexPath.row];
    cell.video = video;
    return cell;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        VFMRemoteVideo *video = self.videos[selectedPath.row];

        VFMWatchVideoViewController *watchVC = (VFMWatchVideoViewController *)segue.destinationViewController;
        watchVC.video = video;
    }
}

@end
