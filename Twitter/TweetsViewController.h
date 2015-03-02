//
//  TweetsViewController.h
//  Twitter
//
//  Created by Peter Bai on 2/16/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TimelineType) {
    TimelineTypeHome = 0,
    TimelineTypeUser = 1,
    TimelineTypeMentions = 2
};

@class TweetsViewController;

@protocol TweetsViewControllerDelegate <NSObject>

- (void)menuButtonTappedByTweetsViewController:(TweetsViewController *)tvc;

@end

@interface TweetsViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (assign, nonatomic) TimelineType timelineType;
@property NSMutableDictionary *estimatedRowHeightCache;
@property (weak, nonatomic) id<TweetsViewControllerDelegate> delegate;

@end
