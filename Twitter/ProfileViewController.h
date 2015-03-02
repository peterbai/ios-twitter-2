//
//  ProfileViewController.h
//  Twitter
//
//  Created by Peter Bai on 2/28/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class ProfileViewController;

@protocol ProfileViewControllerDelegate <NSObject>

- (void)menuButtonTappedByProfileViewController:(ProfileViewController *)profileViewController;

@end

@interface ProfileViewController : UIViewController

@property (assign, nonatomic) BOOL isCurrentUser;
@property NSMutableDictionary *estimatedRowHeightCache;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) id<ProfileViewControllerDelegate> delegate;

@end
