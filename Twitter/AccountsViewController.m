//
//  AccountsViewController.m
//  Twitter
//
//  Created by Peter Bai on 3/1/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "AccountsViewController.h"

@interface AccountsViewController ()

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // set up nav bar
        UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburgerMenuButton"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
        [menuButtonItem setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"AvenirNext-Regular" size:18.0],NSFontAttributeName,
          nil]forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = menuButtonItem;

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85.0/255
                                                                           green:172.0/255
                                                                            blue:238.0/255
                                                                           alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *navBarAttributes = [NSDictionary
                                      dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-DemiBold" size:20], NSFontAttributeName,
                                      [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navBarAttributes];
    
    // make nav bar fully transparent
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onMenu {
    [self.delegate menuButtonTappedByAccountsViewController:self];
}

@end
