//
//  PhraseCell.m
//  音频demo
//
//  Created by runlhy on 15/12/5.
//  Copyright © 2015年 runlhy. All rights reserved.
//

#import "PhraseCell.h"

@implementation PhraseCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//自定义cell 分割线
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 111.0/255, 128.0/255, 154.0/255, 1.0);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height-2, rect.size.width, 3));
}

@end
