//
//  Lyric.m
//  HYMusic
//
//  Created by iceAndFire on 15/10/13.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import "Lyric.h"

@implementation Lyric

- (id) initWtinLyric:(NSString *)lyric time:(NSInteger )time
{
    if (self = [super init]) {
        self.lyric = lyric;
        self.time = time;
    }
    return self;
}
- (id) lyticWtinLyric:(NSString *)lyric time:(NSInteger )time
{
    return [[Lyric alloc] initWtinLyric:lyric time:time];
}

@end
