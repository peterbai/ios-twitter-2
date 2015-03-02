//
//  MenuOptionCell.m
//  Twitter
//
//  Created by Peter Bai on 2/27/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "MenuOptionCell.h"

@implementation MenuOptionCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.menuTitleLabel.textColor = [UIColor colorWithRed:86.0 / 255
                                                        green:173.0 / 255
                                                         blue:238.0 / 255
                                                        alpha:1.0];
    }
    else {
        self.menuTitleLabel.textColor = [UIColor whiteColor];
    }
}


@end
