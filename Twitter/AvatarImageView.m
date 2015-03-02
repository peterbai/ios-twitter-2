//
//  AvatarImageView.m
//  Twitter
//
//  Created by Peter Bai on 2/28/15.
//  Copyright (c) 2015 Peter Bai. All rights reserved.
//

#import "AvatarImageView.h"

@implementation AvatarImageView

- (void)awakeFromNib {
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 3.0;
}

@end
