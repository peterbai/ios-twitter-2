//
//  SwipeInteractionController.m
//  Twitter
//
//  Created by Peter Bai on 2/26/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "SwipeInteractionController.h"

@interface SwipeInteractionController () <UIViewControllerTransitioningDelegate>

@end

@implementation SwipeInteractionController {
    BOOL _shouldCompleteTransition;
    UIViewController *_presentingViewController;
}

- (void)wireToViewController:(UIViewController *)viewController {
    _presentingViewController = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}

- (void)prepareGestureRecognizerInView:(UIView *)view {
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleGesture:)];
    [view addGestureRecognizer:gesture];
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            // start an interactive transition
            self.interactionInProgress = YES;

            // Instantiate the menu view controller
            self.menuViewController = [[MenuViewController alloc] init];
            self.menuViewController.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)_presentingViewController;
            self.menuViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            // Present the controller
            [_presentingViewController presentViewController:self.menuViewController animated:YES completion:nil];
            break;
            
        case UIGestureRecognizerStateChanged: {
            NSLog(@"pan position: %f, %f", translation.x, translation.y);
            // compute current position
            CGFloat fraction = - (translation.x / 200.0);
            fraction = fminf(fmaxf(fraction, 0.0), 0.99);
            
            // determine whether we should complete
            _shouldCompleteTransition = (fraction > 0.5);
            
            // update the animation
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            NSLog(@"gesture ended or cancelled");
            // finish or cancel
            self.interactionInProgress = NO;
            if (!_shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
                NSLog(@"cancelled interactive transition");
            }
            else {
                [self finishInteractiveTransition];
                NSLog(@"ended interactive transition");
            }
            break;

        default:
            break;
    }
}

@end
