//
//  Lyric.h
//  HYMusic
//
//  Created by iceAndFire on 15/10/13.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lyric : NSObject
//时间 内容
@property (nonatomic, copy) NSString *lyric;
@property (nonatomic, assign) NSInteger time;

- (id) initWtinLyric:(NSString *)lyric time:(NSInteger )time;
- (id) lyticWtinLyric:(NSString *)lyric time:(NSInteger )time;
@end
