//
//  MenuAnimationController.m
//  Twitter
//
//  Created by Peter Bai on 2/24/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "MenuAnimationController.h"

@implementation MenuAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    // obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    // obtain the container view
    UIView *containerView = [transitionContext containerView];
    
    // set initial state
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
    
    // add the view
    [containerView addSubview:toViewController.view];
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // set the state to animate to
                         fromViewController.view.alpha = 0.5;
                         toViewController.view.frame = finalFrame;
                     } completion:^(BOOL finished) {
                         // inform the context of completion
                         fromViewController.view.alpha = 1.0;
//                         [transitionContext completeTransition:YES];
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
