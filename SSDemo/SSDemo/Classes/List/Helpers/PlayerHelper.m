//
//  PlayerHelper.m
//  HYMusic
//
//  Created by iceAndFire on 15/10/12.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import "PlayerHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerHelper ()
#pragma mark - 声明私有属性
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation PlayerHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        //监听并且通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didToStop) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        

        //设置播放会话，在后台可以继续播放（还需要设置程序允许后台运行模式）
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if(![[AVAudioSession sharedInstance] setActive:YES error:nil])
        {
            NSLog(@"Failed to set up a session.");
        }

        
    }
    return self;
}
- (void) didToStop
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didStop)]) {
        [self.delegate didStop];
    }
}


#pragma mark - 创建单例方法
+ (instancetype) sharePlayerHelper
{
    static PlayerHelper *playerHelper = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        playerHelper = [PlayerHelper new];
    });
    return playerHelper;
}
//播放本地音频
- (void) playLocalMusicWithURL:(NSString *)url
{
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:url]];
    [self pause];
    //切换当前音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    //这样需要加载才会播放  这里有一个更好的方法 看看你能不能看懂 kov 监听 status 新值 这个属性是什么意思 AVPlayerStatus 枚举 代表播放器的状态，
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self play];
}

//观察者执行事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            //[self play];
            [self pause];
        }
    }
}
//封装 play pause
- (void) play
{
    if (self.isPlay == YES) {
        return;
    }
    else{
        [self.player play];
        self.isPlay = YES;
    }

    if (self.timer != nil) {
        return;
    }
    //每隔 x 秒就让代理执行一个方法，这个方法是传值
    float time = 0.1;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
}
- (void) pause
{
    if (self.isPlay == NO) {
        return;
    }
    else{
        [self.player pause];
        self.isPlay = NO;
    }
    //停止定时器
    [self.timer invalidate];
    self.timer = nil;
}
//代理方法
- (void) timerAction
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playingWithTime:)]) {
        NSTimeInterval time = self.player.currentTime.value / self.player.currentTime.timescale;
        [self.delegate playingWithTime:time];
    }
}


//播放指定时间音乐
- (void) seekToTime:(double)time
{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        [self play];
    }];
    
}
//音量
- (void)setSoundValue:(float)soundValue
{
    self.player.volume = soundValue;
}
- (float)soundValue
{
    return self.player.volume;
}


//获取总时间
- (double) totalAcquisitionTimeWithUrl:(NSString *)musicUrl
{
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicUrl] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

#pragma mark - 懒加载
-(AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

@end
