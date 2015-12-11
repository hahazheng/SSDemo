//
//  UILabel+HYLabel.h
//  音频demo
//
//  Created by runlhy on 15/12/10.
//  Copyright © 2015年 runlhy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HYLabel)

/*
 * 参数：label （用来获取单词相对于label的相对位置）返回分割后的字符串数组 (按照连续的字符切割)
 */
+ (NSArray *)cuttingStringInLabel:(UILabel *)label;

@end
