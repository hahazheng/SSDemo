//
//  DDDViewController.m
//  qqqqqq
//
//  Created by lanou3g on 15/12/5.
//  Copyright © 2015年 党政. All rights reserved.
//

#import "DDDViewController.h"
#import "LyricHelper.h"
#import "Lyric.h"
#import "PlayerHelper.h"

@interface DDDViewController ()<UITableViewDelegate,UITableViewDataSource,PlayerHelperDelegate>


- (IBAction)canelAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)startAction:(id)sender;

@end

static NSString *const reuseIdentifier = @"systemCell";

@implementation DDDViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    //注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    //从头自动播放
    [[PlayerHelper sharePlayerHelper] seekToTime:0.];
    
    [PlayerHelper sharePlayerHelper].delegate = self;
    
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    
    _startButton.layer.borderWidth = 2;
    
    _startButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [self.startButton setTitle:@"暂 停" forState:UIControlStateNormal];
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[PlayerHelper sharePlayerHelper] pause];
}

- (IBAction)canelAction:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)startAction:(id)sender {
    
    if (self.startButton.isSelected) {
        
        self.startButton.selected = NO;
        NSLog(@"开始播放");
        
        [[PlayerHelper sharePlayerHelper] play];
    }
    else
    {
        [self.startButton setTitle:@"播 放" forState:UIControlStateSelected];
        self.startButton.selected  = YES;
        NSLog(@"已经暂停");
        [[PlayerHelper sharePlayerHelper] pause];
    }
    


    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lrcArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Lyric *lyric = self.lrcArray[indexPath.row];
    
    cell.textLabel.text = lyric.lyric;
    cell.textLabel.text = [lyric.lyric stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    cell.textLabel.numberOfLines = 0;
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    
    cell.selectedBackgroundView = ({
        UIView *view = [UIView new];
        view;
    });

    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Lyric *lyric = self.lrcArray[indexPath.row];
    //点击播放语音
    [[PlayerHelper sharePlayerHelper] seekToTime:lyric.time+0.1];

    
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
#pragma PlayerHelper Delegate
//给外界提供当前播放时间 do something
- (void) playingWithTime:(NSTimeInterval)time
{
    static NSInteger indexRow = 0;
    
    //NSLog(@"%lf",time);
    NSIndexPath *index = [NSIndexPath indexPathForRow:[[LyricHelper shareLyricHelper] lyricsWithTime:time] inSection:0];
    
    if (indexRow != index.row) {
        [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:(UITableViewScrollPositionMiddle)];
        
   
        indexRow = index.row;
    }
    
    
}
//告知外界播放结束 do something
- (void) didStop
{
    //将播放完毕并不结束
    [[PlayerHelper sharePlayerHelper] pause];
}@end
