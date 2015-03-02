//
//  MenuViewController.h
//  Twitter
//
//  Created by Peter Bai on 2/24/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>

- (void)menuViewController:(MenuViewController *)menuViewController didSelectMenuWithName:(NSString *)name;

@end

@interface MenuViewController : UIViewController

@property (weak, nonatomic) id<MenuViewControllerDelegate> delegate;

@end
