//
//  ProfileScrollView.m
//  Twitter
//
//  Created by Peter Bai on 2/28/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "ProfileScrollView.h"

@implementation ProfileScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// only handle vertical panning
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.y) > fabs(velocity.x);
}

@end
