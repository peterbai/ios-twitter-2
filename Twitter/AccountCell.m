//
//  AccountCell.m
//  Twitter
//
//  Created by Peter Bai on 3/2/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "AccountCell.h"
#import "AvatarImageView.h"
#import <FXBlurView.h>
#import <UIImageView+AFNetworking.h>

@interface AccountCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet AvatarImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//- (void)setHighlighted:(BOOL)highlighted {
//    
//    NSLog(@"highlighting!");
//    if (highlighted) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.headerImageView.alpha = 0.5;
//        }];
//    } else {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.headerImageView.alpha = 1.0;
//        }];
//    }
//}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.headerImageView.image = [self.headerImageView.image blurredImageWithRadius:10.0 iterations:20.0 tintColor:nil];
}

- (void)setUser:(User *)user{
    _user = user;
    [self initializeLayoutFromUserData];
}

- (void)initializeLayoutFromUserData {
    self.name.text = self.user.name;
    self.screenname.text = [NSString stringWithFormat:@"@%@", self.user.screenname];

    NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileImageUrlOriginal]];
    [self.avatarImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.avatarImageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.avatarImageView.image = image;
                        } completion: nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Failed to retrieve profile image: %@", error);
    }];
    
    NSURLRequest *imageRequestBanner = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileBannerUrlMedium]];
    [self.headerImageView setImageWithURLRequest:imageRequestBanner placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.headerImageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.headerImageView.image = [image blurredImageWithRadius:10.0 iterations:20.0 tintColor:nil];
                        } completion:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Failed to retrieve profile image: %@", error);
    }];
}

@end
