//
//  NSString+HYNSString.m
//  音频demo
//
//  Created by runlhy on 15/12/5.
//  Copyright © 2015年 runlhy. All rights reserved.
//

#import "NSString+HYNSString.h"
#import "HYWord.h"

@implementation NSString (HYNSString)


+ (NSArray *)cuttingString:(NSString *)string Symbol:(NSString *)symbol
{
    NSMutableArray *array = [NSMutableArray array];
    char str[strlen([string UTF8String])];
    strcpy(str, [string UTF8String]);
    const char *delim = [symbol UTF8String];
    char *p;
    [array addObject:[NSString stringWithUTF8String:strtok(str, delim)]];
    while((p = strtok(NULL, delim)))
    {
        [array addObject:[NSString stringWithUTF8String:p]];
    }
    return [array copy];
}

+ (NSArray *)cuttingString:(NSString *)string label:(UILabel *)label
{
    NSMutableArray *array = [NSMutableArray array];
    char str[strlen([string UTF8String])];
    strcpy(str, [string UTF8String]);
    
    char *fun = str;
    int state = 0;
    CGPoint point = CGPointMake(0, 0);
    
    for(;(*fun)!='\0';fun++)
    {
        char *world = malloc(sizeof(char));
        int i = 0;
        while(isalpha(*fun)&&(*fun)!='\0')
        {
            //putchar(*fun);
            world[i++] = *fun;
            fun++;
            state=1;
        }
        //处理完当前单词
        if(state)
        {
            world[i] = '\0';
            HYWord *hyword = [HYWord new];
            hyword.wordString = [NSString stringWithUTF8String:world];
            
            CGSize wordSize   = [hyword.wordString sizeWithAttributes:@{NSFontAttributeName:label.font}];
            
            
            //处理计算最后一个单词与符号是连在一起的问题
            NSString *letterStr = [NSString stringWithFormat:@"%c", *(fun)];
            CGSize letterSize   = [letterStr sizeWithAttributes:@{NSFontAttributeName:label.font}];
            if ([letterStr isEqualToString:@" "]) {
                letterSize.width = 0;
            }
            if (point.x + wordSize.width + letterSize.width > label.bounds.size.width) {
                point.x = 0;
                point.y += wordSize.height;
            }
            
            hyword.frame = CGRectMake(point.x, point.y, wordSize.width, wordSize.height);
            
            //单词累加宽
            point.x += wordSize.width;
            
            [array addObject:hyword];
            //printf("%s\n",world);
            // NSLog(@"⭕️%s %@",world, NSStringFromCGRect(hyword.frame));
        }
        state=0;
        
        if (*fun == '(') {
            break;
        }
        
        NSString *letterStr = [NSString stringWithFormat:@"%c", *fun];
        CGSize letterSize   = [letterStr sizeWithAttributes:@{NSFontAttributeName:label.font}];
        //无关字符累加宽
        point.x += letterSize.width;
    }
    return [array copy];
}

@end
