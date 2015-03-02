//
//  AccountsViewController.m
//  Twitter
//
//  Created by Peter Bai on 3/1/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "AccountAddCell.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountAddCell" bundle:nil] forCellReuseIdentifier:@"AccountAddCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

- (void)onMenu {
    [self.delegate menuButtonTappedByAccountsViewController:self];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.accounts.count;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row == 0) {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
        cell.user = [User currentUser];
        return cell;
    } else {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountAddCell"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
@end
