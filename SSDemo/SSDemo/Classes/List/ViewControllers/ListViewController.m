//
//  ListViewController.m
//  Senmiao
//
//  Created by lanou3g on 15/11/23.
//  Copyright © 2015年 党政. All rights reserved.
//

#import "ListViewController.h"
#import "Header.h"
#import "DZRecordView.h"
#import "LVRecordTool.h"
#import "LyricHelper.h"
#import "Lyric.h"
#import "PlayerHelper.h"
#import "PhraseCell.h"
#import "UILabel+HYLabel.h"
#import "HYWord.h"
#import "CHMagnifierView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
//#import "DDDViewController.h"
@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,PlayerHelperDelegate>
{
    double endTime;
    double musicDuration;
    NSInteger currentIndex;
    NSTimeInterval currentTime;

}
//存储歌词
@property (nonatomic, strong) NSArray *lrcArray;
//选中的单词
@property (nonatomic, copy)NSString *currentWord;
//单词选中view
@property (nonatomic, strong) UIView *wordView;
//放大镜
@property (strong, nonatomic) CHMagnifierView *magnifierView;
//自动播放
@property (nonatomic, assign) BOOL isAutoPlay;

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) DZRecordView * recordView;
@property (nonatomic,strong) LVRecordTool * recordtool;
@property (nonatomic,strong) UIImageView * imgView;

@end

static NSString *const reuseIdentifier = @"PhraseCell";

@implementation ListViewController

#pragma mark - 单例方法
+ (instancetype) shareListViewController
{
    static ListViewController *listVC = nil;
    if (listVC == nil) {
        listVC = [[ListViewController alloc] init];
    }
    return listVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 50)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    self.recordView = [DZRecordView recordView];
    self.recordView.frame = CGRectMake(0,kScreenHeight - 50, kScreenWidth, 50);
    _recordView.backgroundColor = [UIColor whiteColor];
    __weak typeof (self) weakSelf = self;
    self.recordView.block = ^(NSString * name){
        
        __strong typeof (self) strongSelf = weakSelf;
        
        strongSelf.imgView.hidden = NO;
        
        strongSelf.imgView.image = [UIImage imageNamed:name];
     
    };
    self.recordView.hBlock = ^(){
        
        __strong typeof (self) strongSelf = weakSelf;
        
         strongSelf.imgView.hidden = YES;
    };
    [self.view addSubview:_recordView];
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.418 alpha:1.000];
    [_recordView addSubview:lineView];
    

    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth / 2 - 100, 64, 200, 30)];
    _imgView.layer.cornerRadius = 5;
    _imgView.layer.masksToBounds = YES;
    [self.view addSubview:_imgView];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"PhraseCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    //添加长按手势
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = .5;
    [self.tableView addGestureRecognizer:longPressGr];
    
    
    //设置代理
    [PlayerHelper sharePlayerHelper].delegate = self;
    
    //自动播放
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"自动播放" style:UIBarButtonItemStylePlain target:self action:@selector(autoplay)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 89.5;
    
    //去掉cell 分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //初始化数据
    _curretnLenssonNumber = -1;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_lessonNumber != _curretnLenssonNumber) {
        [self loadLocalDataWithLessonNumber:_lessonNumber];
        [self.tableView reloadData];
    }
}
//长按的方法
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [gesture locationInView:self.tableView];
            //设置放大镜位置
            [self magnifierPosition:point];
            //显示放大镜
            [self.magnifierView makeKeyAndVisible];
            //获取cell 及其label上的单词
            [self wordsOnCell:point];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self.tableView];
            //设置放大镜位置
            [self magnifierPosition:point];
            //获取cell 及其label上的单词
            [self wordsOnCell:point];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [gesture locationInView:self.tableView];
            //长按结束取消放大镜
            [self.magnifierView setHidden:YES];
            //获取cell 及其label上的单词
            [self wordsOnCell:point];
            //调用系统词典显示
            if (self.wordView.isHidden == NO) {
                [self systemDictionarie:self.currentWord];
            }
            break;
        }
        default:
            break;
    }
    
}
//设置放大镜位置
-(void)magnifierPosition:(CGPoint)point
{
    //设置放大镜的位置
    CGPoint magnifierPoint = point;
    int y = magnifierPoint.y - self.tableView.contentOffset.y - 30;
    magnifierPoint.y = y;
    self.magnifierView.pointToMagnify = magnifierPoint;
}
//获取cell 及其label上的单词
- (void)wordsOnCell:(CGPoint)point
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    if(indexPath == nil)
        return ;
    PhraseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //这个方法会提供 单词的 相对父视图的位置
    NSArray *strArray = [UILabel cuttingStringInLabel:cell.phraseLabel];
    for (HYWord *hyword in strArray) {
        CGRect frame = hyword.frame;
        frame.origin.x += cell.frame.origin.x + 20;
        frame.origin.y += cell.frame.origin.y + 20;
        if ([self pointInRectangle:frame point:point]) {
            self.wordView.hidden = NO;
            self.wordView.frame = frame;
            self.wordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.8 alpha:.5];
            self.wordView.layer.cornerRadius = 3;
            self.wordView.layer.masksToBounds = YES;
            [self.tableView addSubview:self.wordView];
            self.currentWord = hyword.wordString;
            return;
        }
    }
    self.wordView.hidden = YES;
}
//调用系统词典
- (void) systemDictionarie:(NSString *)word
{
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = .5;
    [self.view.window addSubview:view];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 子线程
        UIReferenceLibraryViewController *referenceLibraryViewController =[[UIReferenceLibraryViewController alloc] initWithTerm:word];
        
        // 主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [view removeFromSuperview];
            
            [self presentViewController:referenceLibraryViewController
                               animated:YES
                             completion:nil];
            self.wordView.hidden = YES;
        });
    });
}
//判断点在矩形内
- (BOOL) pointInRectangle:(CGRect )rech point:(CGPoint)clickPoint
{
    if (clickPoint.x > rech.origin.x && clickPoint.x < (rech.origin.x + rech.size.width) && clickPoint.y > rech.origin.y  &&  clickPoint.y < (rech.origin.y + rech.size.height)) {
        return YES;
    }
    return NO;
}

#pragma mark - 自动播放按钮
- (void) autoplay
{
    /*
     *根据项目需求，自动播放在当前页面播放
     *实现规则如下：
     *设置标识位，标识为自动播放，取消则为点击播放。
     *存为属性 isAutoPlay
     
    //弹出自动播放
    DDDViewController *dddViewController = [DDDViewController new];
    //拿到歌词
    dddViewController.lrcArray = self.lrcArray;
    
    [self.navigationController pushViewController:dddViewController animated:YES];
     */
    
    //点击播放语音
    [[PlayerHelper sharePlayerHelper] play];
    
//    _isAutoPlay = _isAutoPlay?NO:YES;
    
    if (_isAutoPlay) {
        _isAutoPlay = NO;
        
        //关闭屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        
        self.navigationItem.rightBarButtonItem.title = @"自动播放";
    }else{
        _isAutoPlay = YES;
        
        //设置屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        self.navigationItem.rightBarButtonItem.title = @"停止播放";
    }
    
}

//加载本地数据
- (void) loadLocalDataWithLessonNumber:(NSInteger)lenssonNumber;
{
    endTime = 0;
    
    _curretnLenssonNumber = lenssonNumber;
    
    NSString *lessonName = [NSString stringWithFormat:@"oral8000_%ld",lenssonNumber+1];
    //1.从包内容获取歌词
    NSString *lrcString = [[NSString alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:lessonName ofType:@"lrc"] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@",textString);
    
    //2.分隔歌词
    [[LyricHelper shareLyricHelper] splitTheLyrics:lrcString];
    //获取歌词
    self.lrcArray = [NSArray arrayWithArray:[LyricHelper shareLyricHelper].allDataArray];
    
    //加载本地音频
    NSString *mp3Url = [[NSBundle mainBundle] pathForResource:lessonName ofType:@"mp3"];
    
    [[PlayerHelper sharePlayerHelper] playLocalMusicWithURL: mp3Url];
    
    //获取歌曲时间
    musicDuration = [[PlayerHelper sharePlayerHelper] totalAcquisitionTimeWithUrl:mp3Url];
    
    //暂停
    [self pauseMusic];
    NSLog(@"%@",NSStringFromCGRect( self.tableView.frame));
    self.tableView.contentOffset = CGPointMake(0, 0);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lrcArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Lyric *lyric = self.lrcArray[indexPath.row];
    
    //鉴于 党政的不负责任，这里需要将 意大利语与汉语交换位置。
    NSArray *compentsArray = [lyric.lyric componentsSeparatedByString:@")"];
    
    if (compentsArray.count == 2) {
        
        NSString *firstString = compentsArray[0];
        
        NSString *lastString = compentsArray[1];
        //中文翻译补“ ）”
        firstString = [firstString stringByAppendingString:@")"];
        cell.phraseLabel.text = lastString;
        cell.chineseLabel.text = firstString;
    }
    //选中cell的颜色
    cell.phraseLabel.highlightedTextColor = [UIColor colorWithRed:40.0/255 green:80.0/255 blue:226.0/255 alpha:1];
    
    cell.selectedBackgroundView = ({
        UIView *view = [UIView new];
        view;
    });
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentIndex = indexPath.row;
    
    Lyric *lyric = self.lrcArray[indexPath.row];
    //点击播放语音
    [[PlayerHelper sharePlayerHelper] seekToTime:lyric.time];
    
    //选中cell的效果
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
    
    if (self.lrcArray.count == indexPath.row + 1) {
        endTime = MAXFLOAT;
        return;
    }
    
    //保存结束时间
    Lyric *lyricTemp = self.lrcArray[indexPath.row + 1];
    endTime = lyricTemp.time;
}


#pragma PlayerHelper Delegate
//给外界提供当前播放时间 do something
- (void) playingWithTime:(NSTimeInterval)time
{
    if (_isAutoPlay) {
        
        currentTime = time;
        
        //自动播放模式
        static NSInteger indexRow = 0;
        NSIndexPath *index = [NSIndexPath indexPathForRow:[[LyricHelper shareLyricHelper] lyricsWithTime:time] inSection:0];
        
        if (indexRow != index.row) {
            [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
            
            currentIndex = index.row;
            
            [self configNowPlayingInfoCenter];
            
            indexRow = index.row;
        }
    }
    //点播模式
    else if(endTime <= time) {
        //结束接受远程事件
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
        [[PlayerHelper sharePlayerHelper] pause];
    }
}
//告知外界播放结束 do something
- (void) didStop
{
    //将播放完毕并不结束
    [[PlayerHelper sharePlayerHelper] pause];
}

#pragma mark - 上一曲 下一曲 暂停 播放
- (void)pauseMusic
{
    NSLog(@"暂停音乐");
    self.navigationItem.rightBarButtonItem.title = @"自动播放";
    [[PlayerHelper sharePlayerHelper] pause];
    
}
- (void)playMusic
{
    [[PlayerHelper sharePlayerHelper] play];
}
- (void)PreviousMusic
{
    Lyric *lyric = self.lrcArray[currentIndex - 1 < 0?0:currentIndex-1];
    [[PlayerHelper sharePlayerHelper] seekToTime:lyric.time];
    
}
- (void)nextMusic
{
    Lyric *lyric = self.lrcArray[currentIndex + 1 >= _lrcArray.count?_lrcArray.count - 1:currentIndex + 1];
    [[PlayerHelper sharePlayerHelper] seekToTime:lyric.time];
}

#pragma mark - 设置锁屏播放器信息
-(void)configNowPlayingInfoCenter
{
    
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        //要一个字典存放要显示的信息
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        //歌曲名称
        Lyric *lyric = self.lrcArray[currentIndex];
        NSArray *compentsArray = [lyric.lyric componentsSeparatedByString:@")"];
        
        if (compentsArray.count == 2) {
            [dict setObject:compentsArray[1] forKey:MPMediaItemPropertyTitle];
        }
        
        //演唱者
        [dict setObject:@"演唱者" forKey:MPMediaItemPropertyArtist];
        //专辑名
        [dict setObject:@"专辑名" forKey:MPMediaItemPropertyAlbumTitle];
        //专辑缩略图
        /*
        if (self.playerImgView.image != nil){
            UIImage *image = self.playerImgView.image;
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
            [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        }
         */
        //音乐剩余时长
        [dict setObject:[NSNumber numberWithDouble:musicDuration] forKey:MPMediaItemPropertyPlaybackDuration];
        
        //        音乐当前播放时间 在计时器中修改
        [dict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        //设置锁屏状态下屏幕显示播放音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

#pragma mark -lazy
- (CHMagnifierView *)magnifierView
{
    if (!_magnifierView) {
        _magnifierView = [[CHMagnifierView alloc] init];
        _magnifierView.viewToMagnify = self.tableView.window;
    }
    return _magnifierView;
}

- (UIView *)wordView
{
    if (!_wordView) {
        _wordView = [[UIView alloc] init];
    }
    return _wordView;
}
@end
