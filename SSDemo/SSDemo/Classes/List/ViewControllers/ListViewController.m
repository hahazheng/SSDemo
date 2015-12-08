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
#import "NSString+HYNSString.h"
#import "HYWord.h"
#import "CHMagnifierView.h"
#import "DDDViewController.h"
@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,PlayerHelperDelegate>
{
    double endTime;
}
//存储歌词
@property (nonatomic, strong) NSArray *lrcArray;
//单词选中view
@property (nonatomic, strong) UIView *wordView;
//放大镜
@property (strong, nonatomic) CHMagnifierView *magnifierView;


@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) DZRecordView * recordView;
@property (nonatomic,strong) LVRecordTool * recordtool;
@property (nonatomic,strong) UIImageView * imgView;

@end

static NSString *const reuseIdentifier = @"PhraseCell";

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
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
    
    //加载本地数据
    [self loadLocalData];
    
    //设置代理
    [PlayerHelper sharePlayerHelper].delegate = self;
    
    //自动播放
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"自动播放" style:UIBarButtonItemStylePlain target:self action:@selector(autoplay)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.estimatedRowHeight = 100;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [PlayerHelper sharePlayerHelper].delegate = self;
}

//长按的方法
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //在长按开始的时候计算出
            //获取长按的cell
            
            NSLog(@"长按开始");
            
            if (self.magnifierView == nil) {
                self.magnifierView = [[CHMagnifierView alloc] init];
                self.magnifierView.viewToMagnify = self.tableView.window;
            }
            CGPoint magnifierPoint = [gesture locationInView:self.tableView];
            int y = magnifierPoint.y - self.tableView.contentOffset.y - 30;
            magnifierPoint.y = y;
            
            self.magnifierView.pointToMagnify = magnifierPoint;
            [self.magnifierView makeKeyAndVisible];
            
            CGPoint point = [gesture locationInView:self.tableView];
            NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
            if(indexPath == nil)
                return ;
            PhraseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //这个方法会提供 单词的 相对父视图的位置
            NSArray *strArray = [NSString cuttingString:cell.phraseLabel.text label:cell.phraseLabel];
            for (HYWord *hyword in strArray) {
                CGRect frame = hyword.frame;
                frame.origin.x += cell.frame.origin.x + 20;
                frame.origin.y += cell.frame.origin.y + 20;
                if ([self pointInRectangle:frame point:point]) {
                    [self.wordView removeFromSuperview];
                    self.wordView = [[UIView alloc] initWithFrame:frame];
                    self.wordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.8 alpha:.5];
                    [self.tableView addSubview:self.wordView];
                    return;
                }
            }
            //将wordView从父视图(tableView)上移除
            [self.wordView removeFromSuperview];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            //在移动的时候
            CGPoint point = [gesture locationInView:self.tableView];
            
            //设置放大镜的位置
            CGPoint magnifierPoint = point;
            int y = magnifierPoint.y - self.tableView.contentOffset.y - 30;
            magnifierPoint.y = y;
            
            self.magnifierView.pointToMagnify = magnifierPoint;
            NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
            if(indexPath == nil)
                return ;
            PhraseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //这个方法会提供 单词的 相对父视图的位置
            NSArray *strArray = [NSString cuttingString:cell.phraseLabel.text label:cell.phraseLabel];
            for (HYWord *hyword in strArray) {
                CGRect frame = hyword.frame;
                frame.origin.x += cell.frame.origin.x + 20;
                frame.origin.y += cell.frame.origin.y + 20;
                if ([self pointInRectangle:frame point:point]) {
                    [self.wordView removeFromSuperview];
                    self.wordView = [[UIView alloc] initWithFrame:frame];
                    self.wordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.8 alpha:.5];
                    [self.tableView addSubview:self.wordView];
                    return;
                }
            }
            [self.wordView removeFromSuperview];
            //NSLog(@"长按改变 %@", NSStringFromCGPoint(point));
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //长按结束取消放大镜
            [self.magnifierView setHidden:YES];
            //获取长按的cell
            CGPoint point = [gesture locationInView:self.tableView];
            NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
            if(indexPath == nil)
                return ;
            PhraseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //NSLog(@"长按结束 %@ %@",NSStringFromCGPoint(point), NSStringFromCGRect(cell.frame));
            [self.wordView removeFromSuperview];
            //这个方法会提供 单词的 相对父视图的位置
            NSArray *strArray = [NSString cuttingString:cell.phraseLabel.text label:cell.phraseLabel];
            for (HYWord *hyword in strArray) {
                CGRect frame = hyword.frame;
                frame.origin.x += cell.frame.origin.x + 20;
                frame.origin.y += cell.frame.origin.y + 20;
                if ([self pointInRectangle:frame point:point]) {
                    NSLog(@"%@",hyword.wordString);
                    return;
                }
            }
            break;
        }
        default:
            break;
    }
    
}
//判断点在矩形内
- (BOOL) pointInRectangle:(CGRect )rech point:(CGPoint)clickPoint
{
    if (clickPoint.x > rech.origin.x && clickPoint.x < (rech.origin.x + rech.size.width) && clickPoint.y > rech.origin.y  &&  clickPoint.y < (rech.origin.y + rech.size.height)) {
        return YES;
    }
    return NO;
}
- (void) autoplay
{
    
      //弹出自动播放
    DDDViewController * dddVC = [[DDDViewController alloc]init];
        //拿到歌词
    dddVC.lrcArray = self.lrcArray;
    
    [self presentViewController:dddVC animated:YES completion:nil];
}

//加载本地数据
- (void) loadLocalData
{
    //1.从包内容获取歌词
    NSString *lrcString = [[NSString alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oral8000_1" ofType:@"lrc"] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@",textString);
    
    //2.分隔歌词
    [[LyricHelper shareLyricHelper] splitTheLyrics:lrcString];
    //获取歌词
    self.lrcArray = [NSArray arrayWithArray:[LyricHelper shareLyricHelper].allDataArray];
    
    //加载本地音频
    NSString *mp3Url = [[NSBundle mainBundle] pathForResource:@"oral8000_1" ofType:@"mp3"];
    
    [[PlayerHelper sharePlayerHelper] playLocalMusicWithURL: mp3Url];
    
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
    
    cell.phraseLabel.text = [lyric.lyric stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Lyric *lyric = self.lrcArray[indexPath.row];
    //点击播放语音
    [[PlayerHelper sharePlayerHelper] seekToTime:lyric.time];
    
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
    //NSLog(@"1%lf",time);
    if (endTime <= time) {
        [[PlayerHelper sharePlayerHelper] pause];
    }
}
//告知外界播放结束 do something
- (void) didStop
{
    //将播放完毕并不结束
    [[PlayerHelper sharePlayerHelper] pause];
}





@end
