//
//  MenuTapGestureRecognizer.m
//  Twitter
//
//  Created by Peter Bai on 3/1/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "MenuTapGestureRecognizer.h"

@implementation MenuTapGestureRecognizer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    UIView *view = tapGestureRecognizer.view;
    CGPoint location = [tapGestureRecognizer locationInView:view];
    
    NSLog(@"location: %@, framesize: %@", NSStringFromCGPoint(location), NSStringFromCGRect(view.frame));
    
    if (location.x < view.frame.size.width * 0.8125) {
        NSLog(@"returned no");
        return NO;
    }
    return YES;
}

@end
