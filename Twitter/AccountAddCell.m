//
//  AccountAddCell.m
//  Twitter
//
//  Created by Peter Bai on 3/2/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "AccountAddCell.h"

@interface AccountAddCell ()

@property (weak, nonatomic) IBOutlet UIImageView *plusImage;

@end

@implementation AccountAddCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [UIView animateWithDuration:0.3 animations:^{
            self.plusImage.alpha = 0.5;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.plusImage.alpha = 1.0;
        }];
    }
}

@end
