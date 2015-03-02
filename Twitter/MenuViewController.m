//
//  MenuViewController.m
//  Twitter
//
//  Created by Peter Bai on 2/24/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuOptionCell.h"

typedef NS_ENUM(NSInteger, MenuOption) {
    MenuOptionTimeline = 0,
    MenuOptionMentions = 1,
    MenuOptionProfile = 2,
    MenuOptionAccounts = 3
};

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGFloat topInset = 150;
    CGFloat leftInset = 0;
    CGFloat bottomInset = 0;
    CGFloat rightInset = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuOptionCell" bundle:nil] forCellReuseIdentifier:@"MenuOptionCell"];
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
- (IBAction)onDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == MenuOptionTimeline) {
        MenuOptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell"];
        cell.menuTitleLabel.text = @"Timeline";
        return cell;
    }
    else if (indexPath.row == MenuOptionMentions) {
        MenuOptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell"];
        cell.menuTitleLabel.text = @"Mentions";
        return cell;
    }
    else if (indexPath.row == MenuOptionProfile) {
        MenuOptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell"];
        cell.menuTitleLabel.text = @"Profile";
        return cell;
    }
    else {
        MenuOptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell"];
        cell.menuTitleLabel.text = @"Accounts";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case MenuOptionProfile:
            [self.delegate menuViewController:self didSelectMenuWithName:@"Profile"];
            break;
        case MenuOptionTimeline:
            [self.delegate menuViewController:self didSelectMenuWithName:@"Timeline"];
            break;
        case MenuOptionMentions:
            [self.delegate menuViewController:self didSelectMenuWithName:@"Mentions"];
            break;
        default:
            break;
    }
}

@end
