//
//  ProfileViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/28/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "ProfileViewController.h"
#import "AvatarImageView.h"
#import <FXBlurView.h>
#import <UIImageView+AFNetworking.h>

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TimelineTweetCell.h"
#import <SVPullToRefresh.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"

CGFloat const headerMinHeight = 40.0;
CGFloat const usernameTransitionStartOffset = 80.0;
CGFloat const headerLabelMaximumTranslationDistance = 46.0;
CGFloat const detailsViewFullyHiddenOffsetY = 152;

@interface ProfileViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
TimelineTweetCellDelegate,
ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIView *headerDetailsView;

@property (weak, nonatomic) IBOutlet UILabel *headerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerTweetsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBlurredImageView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (assign, nonatomic) CGSize tableViewContentSize;
@property (assign, nonatomic) CGFloat tableViewNecessaryContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrollViewXPositionConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *detailSegmentedControl;

@property (weak, nonatomic) IBOutlet UIView *pageViewContainer;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *pageViewPanGestureRecognizer;
@property (assign, nonatomic) NSInteger currentPageViewIndex;
@property (assign, nonatomic) CGPoint pageOneCenterPosition;
@property (assign, nonatomic) CGPoint pageTwoCenterPosition;
@property (assign, nonatomic) CGPoint pageViewStartPosition;
@property (weak, nonatomic) IBOutlet UIPageControl *pageViewControl;

@property (strong, nonatomic) NSMutableArray *tweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeLayoutFromUserData];
    
    // set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileDetailsCell" bundle:nil] forCellReuseIdentifier:@"ProfileDetailsCell"];
    self.tableView.bounces = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCell" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTweetCellRetweeted" bundle:nil] forCellReuseIdentifier:@"TimelineTweetCellRetweeted"];
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableViewHeightConstraint.constant = self.view.frame.size.height - headerMinHeight - statusBarHeight;
    self.tableView.tableFooterView = self.footerView;
    
    // add border between last cell and footer
    CALayer *footerBorder = [CALayer layer];
    footerBorder.frame = CGRectMake(0.0f, 0.0f, self.detailsView.frame.size.width, 0.5f);
    footerBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [self.footerView.layer addSublayer:footerBorder];
    
    // set up scroll view
    self.scrollView.delegate = self;
    CGSize fullContentSize = self.view.bounds.size;
    fullContentSize.height *= 2;
    self.scrollView.contentSize = fullContentSize;
    self.topScrollViewXPositionConstraint.constant = self.view.frame.size.width;
    [self.view addGestureRecognizer:self.scrollView.panGestureRecognizer];

    // set up header
    self.headerBlurredImageView.alpha = 0;
    
    // add bottom border to detailsView
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.detailsView.frame.size.height - 0.5, self.detailsView.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [self.detailsView.layer addSublayer:bottomBorder];
    
    // configure segmentedControl
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"AvenirNext-Regular" size:13], NSFontAttributeName, nil];
    [self.detailSegmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    // set up page view container
    self.pageOneCenterPosition = self.pageViewContainer.center;
    self.pageTwoCenterPosition = CGPointMake(self.pageOneCenterPosition.x - self.view.frame.size.width, self.pageOneCenterPosition.y);
    self.pageViewPanGestureRecognizer.delegate = self;
    self.currentPageViewIndex = 0;
    
    // set up nav bar
    if (self.isCurrentUser) {
        UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburgerMenuButton"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
        [menuButtonItem setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"AvenirNext-Regular" size:18.0],NSFontAttributeName,
          nil]forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = menuButtonItem;
    }
    else {
        UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"customBackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
        [menuButtonItem setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"AvenirNext-Regular" size:18.0],NSFontAttributeName,
          nil]forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = menuButtonItem;
    }
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85.0/255
                                                                           green:172.0/255
                                                                            blue:238.0/255
                                                                           alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *navBarAttributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-DemiBold" size:20], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navBarAttributes];
    
    // make nav bar fully transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    // load tweets
    [self getTimelineTweets];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    // make nav bar fully transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark Custom getters

- (CGSize)tableViewContentSize {
    [self.tableView layoutIfNeeded];
    _tableViewContentSize = self.tableView.contentSize;
    return _tableViewContentSize;
}

- (CGFloat)tableViewNecessaryContentHeight {
    _tableViewNecessaryContentHeight = self.view.bounds.size.height - headerMinHeight;
    return _tableViewNecessaryContentHeight;
}

#pragma mark Custom setters

- (void)setUser:(User *)user{
    _user = user;
    [self initializeLayoutFromUserData];
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

#pragma mark - Delegate methods

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self.scrollView) {
        //        NSLog(@"got scroll from: %@", scrollView);
        return;
    }
    
    CGFloat offset = scrollView.contentOffset.y;
    NSLog(@"offset y: %f", offset);
    
//    CGPoint detailsViewOriginInWindow = [self.view convertPoint:self.detailsView.frame.origin toView:nil];
    
    // set scrollview content size
    CGSize fullContentSize = self.view.bounds.size;
    fullContentSize.height = (detailsViewFullyHiddenOffsetY + self.view.frame.size.height) + [self tableViewContentSize].height - (self.view.frame.size.height - headerMinHeight) + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scrollView.contentSize = fullContentSize;
    
    if (offset > detailsViewFullyHiddenOffsetY) {
        
        // Set everything to transition end state
        // container view
        CGRect scrolledBoundsForContainerView = self.view.bounds;
        scrolledBoundsForContainerView.origin.y = detailsViewFullyHiddenOffsetY;
        self.containerView.bounds = scrolledBoundsForContainerView;
        
        // header and avatar
        CATransform3D avatarTransform = CATransform3DIdentity;
        CATransform3D headerTransform = CATransform3DIdentity;
        headerTransform = CATransform3DTranslate(headerTransform, 0, fmaxf(-headerMinHeight, -offset), 0);
        
        CGFloat avatarScaleFactor = (headerMinHeight / self.avatarImageView.bounds.size.height) / 1.4;
        CGFloat avatarSizeVariation = ((self.avatarImageView.bounds.size.height * (1.0 + avatarScaleFactor)) - self.avatarImageView.bounds.size.height) / 2.0;
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
        CATransform3D labelTransform = CATransform3DMakeTranslation( 0, -headerLabelMaximumTranslationDistance, 0);
        self.headerDetailsView.layer.transform = labelTransform;
        
        // fully blur header image
        self.headerBlurredImageView.alpha = 1.0;
        
        // bring header to front
        if (self.avatarImageView.layer.zPosition >= self.header.layer.zPosition) {
            self.header.layer.zPosition = 2;
        }
        
        // apply final transition state
        self.header.layer.transform = headerTransform;
        self.avatarImageView.layer.transform = avatarTransform;
        
        // Offset tableView
        self.tableView.contentOffset = CGPointMake(0, offset - detailsViewFullyHiddenOffsetY);
        
        return;
    }
    else {
        // Reset tableView offset
        self.tableView.contentOffset = CGPointMake(0, 0);
        
        // prepare for header and avatar transitions
        CATransform3D avatarTransform = CATransform3DIdentity;
        CATransform3D headerTransform = CATransform3DIdentity;
        
        // offset container view
        CGRect scrolledBoundsForContainerView = self.view.bounds;
        scrolledBoundsForContainerView.origin.y = offset;
        self.containerView.bounds = scrolledBoundsForContainerView;
        
        // handle pull to expand image
        if (offset < 0) {
            // make sure header label is hidden and image is fully unblurred
            CATransform3D labelTransform = CATransform3DMakeTranslation( 0, usernameTransitionStartOffset, 0);
            self.headerDetailsView.layer.transform = labelTransform;
            self.headerBlurredImageView.alpha = 0.0;
            
            // pull to expand
            CGFloat headerScaleFactor = -offset / self.header.bounds.size.height;
            CGFloat headerSizeVariation = ((self.header.bounds.size.height * (1.0 + headerScaleFactor)) - self.header.bounds.size.height) / 2.0;
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizeVariation, 0);
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0);
            
            // ensure avatar is on top
            if (self.avatarImageView.layer.zPosition < self.header.layer.zPosition) {
                self.header.layer.zPosition = 0;
            }
        }
        // handle header, avatar, and header label transitions
        else {
            // header
            headerTransform = CATransform3DTranslate(headerTransform, 0, fmaxf(-headerMinHeight, -offset), 0);
            
            // avatar
            CGFloat avatarScaleFactor = (fminf(headerMinHeight, offset) / self.avatarImageView.bounds.size.height) / 1.4;
            CGFloat avatarSizeVariation = ((self.avatarImageView.bounds.size.height * (1.0 + avatarScaleFactor)) - self.avatarImageView.bounds.size.height) / 2.0;
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
            
            // label
            CATransform3D labelTransform = CATransform3DMakeTranslation( 0, fmaxf(-headerLabelMaximumTranslationDistance, usernameTransitionStartOffset - offset), 0);
            self.headerDetailsView.layer.transform = labelTransform;
            
            // blur header image
            self.headerBlurredImageView.alpha = fminf(1.0, (offset - usernameTransitionStartOffset) / headerLabelMaximumTranslationDistance);
            
            // determine whether avatar or header should be on top
            if (offset <= headerMinHeight) {
                if (self.avatarImageView.layer.zPosition < self.header.layer.zPosition) {
                    self.header.layer.zPosition = 0;
                }
            }
            else {
                if (self.avatarImageView.layer.zPosition >= self.header.layer.zPosition) {
                    self.header.layer.zPosition = 2;
                }
            }
        }
        self.header.layer.transform = headerTransform;
        self.avatarImageView.layer.transform = avatarTransform;
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.x) > fabs(velocity.y);
}

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

- (void)profileImageTappedFromTimelineTweetCell:(TimelineTweetCell *)timelineTweetCell {
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    
    if (timelineTweetCell.tweet.retweetedTweet) {
        profileViewController.user = timelineTweetCell.tweet.retweetedTweet.user;
    } else {
        profileViewController.user = timelineTweetCell.tweet.user;
    }
    
    [self.navigationController pushViewController:profileViewController animated:YES];
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

#pragma mark ComposeViewControllerDelegate methods

- (void)composeViewController:(ComposeViewController *)composeViewController didSuccessfullyComposeTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    NSLog(@"adding tweet by %@ into tableview", tweet.user.name);
    [self.tableView reloadData];
}

#pragma mark - Twitter API methods

- (void)getTimelineTweets {
    NSDictionary *params = @{@"user_id" : self.user.userID};
    [[TwitterClient sharedInstance] userTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error getting timeline: %@", error);
            return;
        }
        
        self.tweets = [NSMutableArray arrayWithArray:tweets];
        [self.tableView reloadData];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark Actions

- (IBAction)onPageViewPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    
//    NSLog(@"page view panning: %@, velocity: %@", NSStringFromCGPoint(translation), NSStringFromCGPoint(velocity));
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.pageViewStartPosition = panGestureRecognizer.view.center;
            NSLog(@"setting start position center: %@", NSStringFromCGPoint(self.pageViewStartPosition));
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat minCenterXValue = 0;
            CGFloat maxCenterXValue = self.view.bounds.size.width;
            CGPoint newCenterPosition = CGPointMake(fminf(maxCenterXValue, fmaxf(minCenterXValue, self.pageViewStartPosition.x + translation.x)),
                                              panGestureRecognizer.view.center.y);
            panGestureRecognizer.view.center = newCenterPosition;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            CGFloat minCenterXValue = 0;
            CGFloat maxCenterXValue = self.view.bounds.size.width;
            CGPoint newCenterPosition = CGPointMake(self.pageViewStartPosition.x + translation.x, panGestureRecognizer.view.center.y);
            if (newCenterPosition.x < minCenterXValue || newCenterPosition.x > maxCenterXValue) {
                return;
            }
            
            if (velocity.x < -200) {
                [self setPageViewPage:1 animated:YES];
            } else if (velocity.x > 200) {
                [self setPageViewPage:0 animated:YES];
            }
            
            if (fabsf(translation.x) > self.view.bounds.size.width / 2) {
                NSLog(@"toggling");
                [self togglePageView];
            }
            else {
                [self returnToCurrentPageView];
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)onPageControlChanged:(id)sender {
    [self togglePageView];
}

#pragma mark Private methods

- (void)togglePageView {
    if (self.currentPageViewIndex == 0) {
        [self setPageViewPage:1 animated:YES];
    } else if (self.currentPageViewIndex == 1) {
        [self setPageViewPage:0 animated:YES];
    }
}

- (void)returnToCurrentPageView {
    [self setPageViewPage:self.currentPageViewIndex animated:YES];
}

- (void)setPageViewPage:(NSInteger)pageIndex animated:(BOOL)animated {
    if (pageIndex == 0) {
        if (animated) {
            [UIView animateWithDuration:0.4
                                  delay:0.0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.pageViewContainer.center = self.pageOneCenterPosition;
                                 self.headerImageView.alpha = 1.0;
                             } completion:^(BOOL finished) {
                                 nil;
                             }];
        }
        else {
            self.pageViewContainer.center = self.pageOneCenterPosition;
            self.headerImageView.alpha = 1.0;
        }
        self.currentPageViewIndex = 0;
        self.pageViewControl.currentPage = pageIndex;
    }
    else if (pageIndex == 1) {
        if (animated) {
            [UIView animateWithDuration:0.4
                                  delay:0.0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.pageViewContainer.center = self.pageTwoCenterPosition;
                                 self.headerImageView.alpha = 0.5;
                             } completion:^(BOOL finished) {
                                 nil;
                             }];
        }
        else {
            self.pageViewContainer.center = self.pageTwoCenterPosition;
            self.headerImageView.alpha = 0.5;
        }
        self.currentPageViewIndex = 1;
        self.pageViewControl.currentPage = pageIndex;
    }
    else {
        return;
    }
}

- (void)onNew {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.user = [User currentUser];
    cvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onMenu {
    [self.delegate menuButtonTappedByProfileViewController:self];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializeLayoutFromUserData {
    self.name.text = self.user.name;
    self.screenname.text = [NSString stringWithFormat:@"@%@", self.user.screenname];
    self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", [self.user.numberFollowing intValue]];
    self.numberOfFollowersLabel.text = [NSString stringWithFormat:@"%d", [self.user.numberOfFollowers intValue]];
    self.bio.text = self.user.tagline;
    self.headerNameLabel.text = self.name.text;
    self.headerTweetsLabel.text = [NSString stringWithFormat:@"%@ Tweets", self.user.numberOfTweets];

    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileImageUrlOriginal]];
    [self.avatarImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.avatarImageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.avatarImageView.image = image;
                        } completion: nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Failed to retrieve profile image: %@", error);
    }];

    NSURLRequest *imageRequestBanner = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileBannerUrlMedium]];
    NSLog(@"getting image url:%@", self.user.profileBannerUrlMedium);
    [self.headerImageView setImageWithURLRequest:imageRequestBanner placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.headerImageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.headerImageView.image = image;
                        } completion:^(BOOL finished) {
                            self.headerBlurredImageView.image = [self.headerImageView.image blurredImageWithRadius:10.0 iterations:20.0 tintColor:nil];
                        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Failed to retrieve profile image: %@", error);
    }];
}

- (void)setFooterHeight {

    CGFloat paddingHeight = self.tableViewNecessaryContentHeight - self.tableViewContentSize.height;
    NSLog(@"tableViewNecessaryContentHeight: %F", self.tableViewNecessaryContentHeight);
    NSLog(@"tableview content height: %f", self.tableViewContentSize.height);
    NSLog(@"padding height: %f", paddingHeight);
    
    CGRect frame = self.footerView.frame;
    if (paddingHeight > 100) {
        frame.size.height = paddingHeight;
        self.footerView.frame = frame;
    }
    else {
        frame.size.height = 100;
        self.footerView.frame = frame;
    }
    NSLog(@"footer frame: %@", NSStringFromCGRect(self.footerView.frame));
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


@end
