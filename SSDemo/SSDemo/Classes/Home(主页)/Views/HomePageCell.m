//
//  HomePageCell.m
//  SSDemo
//
//  Created by runlhy on 16/2/14.
//  Copyright © 2016年 党政. All rights reserved.
//

#import "HomePageCell.h"

@implementation HomePageCell

- (void)awakeFromNib {
    
    _numberLabel.layer.cornerRadius = 30;
    _numberLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
