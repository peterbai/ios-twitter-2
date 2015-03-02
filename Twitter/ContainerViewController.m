//
//  ContainerViewController.m
//
//
//  Created by Peter Bai on 2/26/15.
//
//

#import "ContainerViewController.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"

@interface ContainerViewController () <TweetsViewControllerDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate, ProfileViewControllerDelegate>

@property (nonatomic, strong) TweetsViewController *tweetsViewController;
@property (nonatomic, strong) TweetsViewController *mentionsTweetsViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *tweetsNavigationViewController;
@property (strong, nonatomic) UINavigationController *mentionsTweetsNavigationViewController;
@property (strong, nonatomic) UINavigationController *profileNavigationViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) UIView *intermediateView;
@property (nonatomic) BOOL menuDisplayed;
@property (strong, nonatomic) UIViewController *activeViewController;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation ContainerViewController

- (void)viewWillLayoutSubviews {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuViewController = [[MenuViewController alloc] init];
    self.menuViewController.delegate = self;
    
    self.tweetsViewController = [[TweetsViewController alloc] init];
    self.tweetsNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.tweetsViewController];
    self.tweetsViewController.delegate = self;
    self.tweetsViewController.timelineType = TimelineTypeUser;
    
    self.mentionsTweetsViewController = [[TweetsViewController alloc] init];
    self.mentionsTweetsNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.mentionsTweetsViewController];
    self.mentionsTweetsViewController.delegate = self;
    self.mentionsTweetsViewController.timelineType = TimelineTypeMentions;
    
    self.profileViewController = [[ProfileViewController alloc] init];
    self.profileViewController.delegate = self;
    self.profileViewController.user = [User currentUser];
    self.profileViewController.isCurrentUser = YES;
    self.profileNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    
    [self displayViewController:self.menuViewController];
    [self displayViewController:self.tweetsNavigationViewController];
    self.activeViewController = self.tweetsNavigationViewController;
//    [self displayViewController:self.profileNavigationViewController];
    
    NSLog(@"active vc on load: %@", self.activeViewController);
    self.panGestureRecognizer.delegate = self;
    self.menuDisplayed = NO;
    
    NSLog(@"tweets: %@, mentions: %@", self.tweetsNavigationViewController, self.mentionsTweetsNavigationViewController);
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Custom setters

- (void)setMenuDisplayed:(BOOL)menuDisplayed {
    _menuDisplayed = menuDisplayed;
    self.activeViewController.view.userInteractionEnabled = !menuDisplayed;
}

#pragma mark Action methods

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:sender.view];
    CGFloat fraction = (translation.x / 200.0);
    fraction = fminf(fmaxf(fraction, 0.0), 1.0);
    
    CGRect initialMainViewFrame = self.contentView.frame;
    CGRect initialMenuViewFrame = CGRectOffset(self.contentView.frame, -100, 0);
    CGRect finalMainViewFrame = CGRectInset(initialMainViewFrame,
                                            initialMainViewFrame.size.width / 4,
                                            initialMainViewFrame.size.height / 4);
    CGPoint initialCenter = CGPointMake(self.contentView.center.x, self.contentView.center.y);
    CGPoint finalCenter = CGPointMake(self.contentView.frame.size.width + initialMainViewFrame.size.width / 16,
                                      self.contentView.frame.size.height / 2);
    if (!self.menuDisplayed) {
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                NSLog(@"starting gesture to show menu");
                self.menuViewController.view.frame = initialMenuViewFrame;
                self.intermediateView = [self.activeViewController.view snapshotViewAfterScreenUpdates:NO];
                self.intermediateView.frame = initialMainViewFrame;
                
                [self.contentView addSubview:self.intermediateView];
                [self hideViewController:self.activeViewController];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                NSLog(@"pan gesture translation: %f, %f", translation.x, translation.y);
                CGFloat intermediateCenterX = ((1 - fraction) * initialCenter.x) + (fraction * finalCenter.x);
                CGFloat intermediateCenterY = ((1 - fraction) * initialCenter.y) + (fraction * finalCenter.y);
                CGFloat intermediateWidth = ((1 - fraction) * initialMainViewFrame.size.width) + (fraction * finalMainViewFrame.size.width);
                CGFloat intermediateHeight = ((1 - fraction) * initialMainViewFrame.size.height) + (fraction * finalMainViewFrame.size.height);
                CGFloat intermediateMenuPositionX = ((1 - fraction) * initialMenuViewFrame.origin.x + fraction * initialMainViewFrame.origin.x);
                
                self.intermediateView.frame = CGRectMake(0, 0, intermediateWidth, intermediateHeight);
                self.intermediateView.center = CGPointMake(intermediateCenterX, intermediateCenterY);
                self.menuViewController.view.frame = CGRectMake(intermediateMenuPositionX, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                NSLog(@"gesture ended or cancelled");
                if (fraction > 0.5) {
                    NSLog(@"completing with menu show transition");
                    [UIView animateWithDuration:0.3
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.intermediateView.frame = finalMainViewFrame;
                                         self.intermediateView.center = finalCenter;
                                         self.menuViewController.view.frame = initialMainViewFrame;
                                     } completion:^(BOOL finished) {
                                         self.menuDisplayed = YES;
                                     }];
                }
                else {
                    NSLog(@"completing with menu hide transition");
                    CGRect finalMainViewFrame = self.contentView.frame;
                    [UIView animateWithDuration:0.3
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.intermediateView.frame = finalMainViewFrame;
                                     } completion:^(BOOL finished) {
                                         [self.intermediateView removeFromSuperview];
                                         self.intermediateView = nil;
                                         [self displayViewController:self.activeViewController];
                                         self.menuDisplayed = NO;
                                     }];
                }
                break;
            }
            default:
                break;
        }
    }
    else {
        CGFloat fraction = -(translation.x / 200.0);
        fraction = fminf(fmaxf(fraction, 0.0), 1.0);

        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                NSLog(@"starting gesture to hide menu");
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                NSLog(@"pan gesture translation: %f, %f", translation.x, translation.y);
                CGFloat intermediateCenterX = ((1 - fraction) * finalCenter.x) + (fraction * initialCenter.x);
                CGFloat intermediateCenterY = ((1 - fraction) * finalCenter.y) + (fraction * initialCenter.y);
                CGFloat intermediateWidth = ((1 - fraction) * finalMainViewFrame.size.width) + (fraction * initialMainViewFrame.size.width);
                CGFloat intermediateHeight = ((1 - fraction) * finalMainViewFrame.size.height) + (fraction * initialMainViewFrame.size.height);
                
                self.intermediateView.frame = CGRectMake(0, 0, intermediateWidth, intermediateHeight);
                self.intermediateView.center = CGPointMake(intermediateCenterX, intermediateCenterY);
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                NSLog(@"gesture ended or cancelled");
                if (fraction > 0.5) {
                    NSLog(@"completing with menu hide transition");
                    CGRect finalMainViewFrame = self.contentView.frame;
                    [UIView animateWithDuration:0.3
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.intermediateView.frame = finalMainViewFrame;
                                     } completion:^(BOOL finished) {
                                         [self.intermediateView removeFromSuperview];
                                         self.intermediateView = nil;
                                         [self displayViewController:self.activeViewController];
                                         self.menuDisplayed = NO;
                                     }];
                }
                else {
                    NSLog(@"completing with menu show transition");
                    [UIView animateWithDuration:0.3
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.intermediateView.frame = finalMainViewFrame;
                                         self.intermediateView.center = finalCenter;
                                     } completion:^(BOOL finished) {
                                         self.menuDisplayed = YES;
                                     }];
                }
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark TweetsViewControllerDelegate methods

- (void)menuButtonTappedByTweetsViewController:(TweetsViewController *)tvc {
    [self showMenu];
}

#pragma mark MenuViewControllerDelegate methods

- (void)menuViewController:(MenuViewController *)menuViewController didSelectMenuWithName:(NSString *)name {
    NSLog(@"selected menu with name: %@", name);
    if ([name isEqualToString:@"Profile"]) {
        [self goToViewController:self.profileNavigationViewController];
    }
    else if ([name isEqualToString:@"Timeline"]) {
        [self goToViewController:self.tweetsNavigationViewController];
    }
    else if ([name isEqualToString:@"Mentions"]) {
        [self goToViewController:self.mentionsTweetsNavigationViewController];
    }
}

#pragma mark ProfileViewControllerDelegate methods

- (void)menuButtonTappedByProfileViewController:(ProfileViewController *)profileViewController {
    [self showMenu];
}

#pragma mark UIGestureRecognizerDelegate methods

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.x) > fabs(velocity.y);
}

#pragma mark Private methods

- (void)showMenu {
    // set up active viewcontroller transform states
    CGAffineTransform initialTransform = CGAffineTransformIdentity;
    CGAffineTransform finalTransform = CGAffineTransformTranslate(initialTransform, self.view.bounds.size.width / 2.0 + self.view.bounds.size.width / 16 , 0);
    finalTransform = CGAffineTransformScale(finalTransform, 0.5, 0.5);
    
    // set up menu transform states
    CGAffineTransform initialMenuTransform = CGAffineTransformIdentity;
    initialMenuTransform = CGAffineTransformTranslate(initialMenuTransform, -100, 0);
    CGAffineTransform finalMenuTransform = CGAffineTransformIdentity;
    
    // set initial state
    self.menuViewController.view.transform = initialMenuTransform;
    
    // animate to final state
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.activeViewController.view.transform = finalTransform;
                         self.menuViewController.view.transform = finalMenuTransform;
                     } completion:^(BOOL finished) {
                         self.menuDisplayed = YES;
                     }];
}

- (void)hideMenu {
    [self goToViewController:nil];
}

- (void)returnToActiveViewController {
    [self goToViewController:nil];
}

- (void)goToViewController:(UIViewController *)viewController {
    
    NSLog(@"going to vc: %@ from active vc: %@", viewController, self.activeViewController);
    NSLog(@"from and to are equal? %d", (viewController == self.activeViewController));

    // Going to same view controller - just expand the existing intermediate view
    if (!viewController || viewController == self.activeViewController) {
        NSLog(@"going back to currently active vc");
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.activeViewController.view.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             self.menuDisplayed = NO;
                         }];
    }
    
    // Going to different view controller
    else {
        NSLog(@"transitioning to new vc");
        [self addChildViewController:viewController];
        [self.contentView addSubview:viewController.view];
        
        CGAffineTransform initialTransform = CGAffineTransformIdentity;
        initialTransform = CGAffineTransformTranslate(initialTransform, self.view.bounds.size.width / 2.0 + self.view.bounds.size.width / 16 , 0);
        initialTransform = CGAffineTransformScale(initialTransform, 0.5, 0.5);
        
        CGAffineTransform finalTransform = CGAffineTransformIdentity;
        
        viewController.view.transform = initialTransform;
        viewController.view.alpha = 0;

        // animate with keyframes
        [UIView animateKeyframesWithDuration:0.5
                                       delay:0.0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
                                      // keyframe one
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:0.5
                                                                    animations:^{
                                                                        viewController.view.alpha = 1.0;
                                                                    }];
                                      
                                      // keyframe two
                                      [UIView addKeyframeWithRelativeStartTime:0.5
                                                              relativeDuration:0.5
                                                                    animations:^{
                                                                        viewController.view.transform = finalTransform;
                                                                    }];
                                  } completion:^(BOOL finished) {
                                      [viewController didMoveToParentViewController:self];
                                      [self hideViewController:self.activeViewController];
                                      self.activeViewController = viewController;
                                      self.menuDisplayed = NO;
                                      
                                      NSLog(@"end of transition, active vc: %@", self.activeViewController);
                                  }];
    }
}

- (void)hideMenuWithCompletion:(void (^)(bool finished))completion {
    
    // initialize frames
    CGRect finalMainViewFrame = self.contentView.frame;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.intermediateView) {
                             self.intermediateView.frame = finalMainViewFrame;
                         }
                     } completion:^(BOOL finished) {
                         [self.intermediateView removeFromSuperview];
                         self.intermediateView = nil;
                         [self displayViewController:self.activeViewController];
                         self.menuDisplayed = NO;
                         
                         if (completion != nil) {
                             completion(YES);
                         }

                     }];
}

- (void)displayViewController:(UIViewController *)viewController {
    [self displayViewController:viewController animated:NO hideCurrent:NO];
}

- (void)displayViewController:(UIViewController *)viewController animated:(BOOL)animated hideCurrent:(BOOL)hideCurrent {
    [self addChildViewController:viewController];
    viewController.view.frame = self.contentView.frame;
    
    if (animated) {
        viewController.view.alpha = 0.0;
        [self.contentView addSubview:viewController.view];
        [UIView animateWithDuration:0.5
                         animations:^{
                             viewController.view.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             if (hideCurrent && self.activeViewController != viewController) {
                                                                  NSLog(@"hidding current active vc");
                                 [self hideViewController:self.activeViewController];

                             }
                             self.activeViewController = viewController;
                             [viewController didMoveToParentViewController:self];
                         }];
    }
    else {
        [self.contentView addSubview:viewController.view];
        if (hideCurrent && self.activeViewController != viewController) {
            [self hideViewController:self.activeViewController];
        }
        self.activeViewController = viewController;
        [viewController didMoveToParentViewController:self];
    }
}

- (void)hideViewController: (UIViewController *) viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}


@end