//
//  NSString+HYNSString.h
//  音频demo
//
//  Created by runlhy on 15/12/5.
//  Copyright © 2015年 runlhy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (HYNSString)

/*
 * 参数：字符串，分割符，返回分割后的字符串(按照特定字符切割)
 */
+ (NSArray *)cuttingString:(NSString *)string Symbol:(NSString *)symbol;
/*
 * 参数：字符串，label （用来获取相对于父视图的相对位置）返回分割后的字符串 (按照连续的字符切割) 
 */
+ (NSArray *)cuttingString:(NSString *)string label:(UILabel *)label;
@end
