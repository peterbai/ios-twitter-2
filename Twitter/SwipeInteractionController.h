//
//  SwipeInteractionController.h
//  Twitter
//
//  Created by Peter Bai on 2/26/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "TweetsViewController.h"

@interface SwipeInteractionController : UIPercentDrivenInteractiveTransition

- (void)wireToViewController:(UIViewController *)viewController;

@property (nonatomic, assign) BOOL interactionInProgress;
@property (nonatomic, strong) TweetsViewController *tweetsViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;

@end
