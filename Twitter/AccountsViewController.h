//
//  AccountsViewController.h
//  Twitter
//
//  Created by Peter Bai on 3/1/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountsViewController;

@protocol AccountsViewControllerDelegate <NSObject>

- (void)menuButtonTappedByAccountsViewController:(AccountsViewController *)accountsViewController;

@end

@interface AccountsViewController : UIViewController

@property (weak, nonatomic) id<AccountsViewControllerDelegate> delegate;

@end
