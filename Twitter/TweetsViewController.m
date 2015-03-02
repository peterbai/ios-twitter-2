//
//  TweetsViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TimelineTweetCell.h"
#import <SVPullToRefresh.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import "ProfileViewController.h"

@interface TweetsViewController ()
<UITableViewDataSource,
UITableViewDelegate,
TimelineTweetCellDelegate,
ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) NSNumber *lowestID;

@end

@implementation TweetsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tweets = [[NSMutableArray alloc] init];
    
    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCell" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCellRetweeted" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCellRetweeted"];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self getNewTweets];
    }];
    
    // Set up NavigationBar
    switch (self.timelineType) {
        case TimelineTypeHome:
            self.title = @"Home";
            break;
        case TimelineTypeUser:
            self.title = @"User Timeline";
            break;
        case TimelineTypeMentions:
            self.title = @"Mentions";
        default:
            break;
    }

    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburgerMenuButton"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
    [menuButtonItem setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"AvenirNext-Regular" size:18.0],NSFontAttributeName,
      nil]forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = menuButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onNew)];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85.0/255
                                                                        green:172.0/255
                                                                         blue:238.0/255
                                                                        alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-DemiBold" size:20], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    [self getTimelineTweets];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // attach SVPullToRefresh here so that it detects content inset correctly
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self getTimelineTweets];
    }];
}

#pragma mark Actions

- (IBAction)onLogout:(id)sender {
    [User logout];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineTweetCell *cell;
    if ([(Tweet *)self.tweets[indexPath.row] retweetedTweet]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimelineTweetCellRetweeted"];
        
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimelineTweetCell"];
    }

    cell.tweet = self.tweets[indexPath.row];
    cell.delegate = self;
    
    if (![self isEstimatedRowHeightInCache:indexPath]) {
        CGSize cellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(self.view.frame.size.width, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:50.0];
        [self putEstimatedCellHeightToCache:indexPath height:cellSize.height];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getEstimatedCellHeightFromCache:indexPath defaultHeight:41.5];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetViewController *tvc = [[TweetViewController alloc] init];
    tvc.tweet = self.tweets[indexPath.row];
    tvc.composeViewControllerdelegate = self;
    [self.navigationController pushViewController:tvc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

// Create separator at top of tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

#pragma mark - Delegate methods

#pragma mark TimelineTweetCellDelegate methods

- (void)replyInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"replying from timeline!");
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self;
    cvc.user = [User currentUser];
    cvc.inReplyToTweet = timelineTweetCell.tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)retweetInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"retweeting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] retweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to retweet, error: %@", error);
            return;
        }
        NSLog(@"retweeted successfully with response: %@", responseObject);
        timelineTweetCell.tweet.myNewRetweetedTweet = [[Tweet alloc] initWithDictionary:responseObject];
    }];
}

- (void)removeRetweetInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"un-retweeting from timeline!");
    
    NSDictionary *params;
    if (timelineTweetCell.tweet.myNewRetweetedTweet) {
        params = @{@"id" : timelineTweetCell.tweet.myNewRetweetedTweet.tweetIDString};
        
    } else {
        params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    }
    
    [[TwitterClient sharedInstance] removeRetweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to remove retweet, error: %@", error);
            return;
        }
        NSLog(@"removed retweet successfully with response: %@", responseObject);
    }];
}

- (void)favoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"favoriting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] favoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to favorite, error: %@", error);
            return;
        }
        NSLog(@"favorited successfully with response: %@", responseObject);
    }];
}

- (void)removeFavoriteInvokedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    NSLog(@"un-favoriting from timeline!");
    NSDictionary *params = @{@"id" : timelineTweetCell.tweet.tweetIDString};
    
    [[TwitterClient sharedInstance] removeFavoriteWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"failed to un-favorite, error: %@", error);
            return;
        }
        NSLog(@"un-favorited successfully with response: %@", responseObject);
    }];
}

- (void)profileImageTappedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    
    if (timelineTweetCell.tweet.retweetedTweet) {
        profileViewController.user = timelineTweetCell.tweet.retweetedTweet.user;
    } else {
        profileViewController.user = timelineTweetCell.tweet.user;
    }
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark ComposeViewControllerDelegate methods

- (void)composeViewController:(ComposeViewController *)composeViewController didSuccessfullyComposeTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    NSLog(@"adding tweet by %@ into tableview", tweet.user.name);
    [self.tableView reloadData];
}

#pragma mark - Twitter API methods

- (void)getTimelineTweets {
    
    if (self.timelineType == TimelineTypeHome) {
        [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            if (error) {
                NSLog(@"Error getting timeline: %@", error);
                return;
            }
            
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView.pullToRefreshView stopAnimating];
            
            self.lowestID = [(Tweet *)[tweets lastObject] tweetID];
        }];
    }
    else if (self.timelineType == TimelineTypeUser) {
        [[TwitterClient sharedInstance] userTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            if (error) {
                NSLog(@"Error getting timeline: %@", error);
                return;
            }
            
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView.pullToRefreshView stopAnimating];
            
            self.lowestID = [(Tweet *)[tweets lastObject] tweetID];
        }];
    }
    else if (self.timelineType == TimelineTypeMentions) {
        [[TwitterClient sharedInstance] mentionsTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            if (error) {
                NSLog(@"Error getting timeline: %@", error);
                return;
            }
            
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView.pullToRefreshView stopAnimating];
            
            self.lowestID = [(Tweet *)[tweets lastObject] tweetID];
        }];
    }
    else {
        NSLog(@"No timeline type specified");
    }
}

- (void)getNewTweets {
    NSNumber *count = [NSNumber numberWithInt:20];
    NSDictionary *params = @{@"count" : count,
                             @"max_id" : self.lowestID};
    
    NSLog(@"requesting new tweets with params: %@", params);
    [[TwitterClient sharedInstance] userTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving new tweets: %@", error);
            [self.tableView.infiniteScrollingView stopAnimating];
            return;
        }
        
        NSMutableArray *newTweets = [NSMutableArray arrayWithArray:tweets];
        [newTweets removeObjectAtIndex:0];  // remove redundant tweet (max_id is inclusive)
        [self.tweets addObjectsFromArray:newTweets];
        
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];

        self.lowestID = [(Tweet *)[self.tweets lastObject] tweetID];
    }];
}

#pragma mark Private methods

- (void)onNew {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.user = [User currentUser];
    cvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onMenu {
    [self.delegate menuButtonTappedByTweetsViewController:self];
}

#pragma mark - estimated height cache methods

// put height to cache
- (void) putEstimatedCellHeightToCache:(NSIndexPath *) indexPath height:(CGFloat) height {
    [self initEstimatedRowHeightCacheIfNeeded];
    [self.estimatedRowHeightCache setValue:[[NSNumber alloc] initWithFloat:height] forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
}

// get height from cache
- (CGFloat) getEstimatedCellHeightFromCache:(NSIndexPath *) indexPath defaultHeight:(CGFloat) defaultHeight {
    [self initEstimatedRowHeightCacheIfNeeded];
    NSNumber *estimatedHeight = [self.estimatedRowHeightCache valueForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    if (estimatedHeight != nil) {
        //NSLog(@"cached: %f", [estimatedHeight floatValue]);
        return [estimatedHeight floatValue];
    }
    //NSLog(@"not cached: %f", defaultHeight);
    return defaultHeight;
}

// check if height is on cache
- (BOOL) isEstimatedRowHeightInCache:(NSIndexPath *) indexPath {
    if ([self getEstimatedCellHeightFromCache:indexPath defaultHeight:0] > 0) {
        return YES;
    }
    return NO;
}

// init cache
-(void) initEstimatedRowHeightCacheIfNeeded {
    if (self.estimatedRowHeightCache == nil) {
        self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    }
}

// custom [self.tableView reloadData]
-(void) tableViewReloadData {
    // clear cache on reload
    self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    [self.tableView reloadData];
}

#pragma mark - System methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
