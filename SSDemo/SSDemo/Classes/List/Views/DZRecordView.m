//
//  DZRecordView.m
//  Senmiao
//
//  Created by lanou3g on 15/11/25.
//  Copyright © 2015年 党政. All rights reserved.
//

#import "DZRecordView.h"
#import "LVRecordTool.h"
#import "Header.h"

@interface DZRecordView ()

@property (nonatomic,strong) LVRecordTool * recordTool;

//录音的按钮
@property (nonatomic,strong) UIButton * startButton;


@property (nonatomic,strong) UIButton * beginButton;


@property (nonatomic,strong) UIImageView * imageView;



@end
@implementation DZRecordView

+ (instancetype)recordView
{
    
    DZRecordView * recordView = [[DZRecordView alloc]init];
    
    recordView.recordTool = [LVRecordTool sharedRecordTool];

    
    [recordView setUp];
    
    return recordView;
}


- (void)setUp
{
 
    self.beginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    self.beginButton.frame = CGRectMake(277, 7, kScreenWidth - 270 - 14, 37);
    
    _beginButton.layer.cornerRadius = 5;
    
    _beginButton.layer.masksToBounds = YES;
    
    _beginButton.layer.borderWidth = 1;
    
    _beginButton.layer.borderColor = [[UIColor colorWithWhite:0.546 alpha:0.600] CGColor];
    
    [_beginButton setTitle:@"播放" forState:UIControlStateNormal];
    
    [_beginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_beginButton addTarget:self action:@selector(beginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_beginButton];
    
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    _startButton.frame = CGRectMake(10, 7, 260, 37);

    
    [_startButton setTitle:@"按住  说话" forState:UIControlStateNormal];
    
    [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_startButton setTitle:@"松开  结束" forState:UIControlStateHighlighted];
    
    _startButton.layer.cornerRadius = 5;
    
    _startButton.layer.masksToBounds = YES;
    
    
    _startButton.layer.borderWidth = 1;
    
    _startButton.layer.borderColor = [[UIColor colorWithWhite:0.546 alpha:0.600] CGColor];
    
    
    [_startButton addTarget:self action:@selector(recordBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    [_startButton addTarget:self action:@selector(recordBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [_startButton addTarget:self action:@selector(recordBtnTouchDragExit:) forControlEvents: UIControlEventTouchDragExit];
    
    [_startButton addTarget:self action:@selector(recordBtnTouchOutside:) forControlEvents: UIControlEventTouchUpOutside];
    
    [_startButton addTarget:self action:@selector(recordBtnTouchDragEnter:) forControlEvents: UIControlEventTouchDragEnter];
    
    [self addSubview:_startButton];

}

- (void)recordBtnTouchDown:(UIButton *)sender
{
    
    [self.recordTool startRecording];
    
     NSString * str = @"shang";
    
    self.block(str);
    
    NSLog(@"上滑取消");

}
- (void)recordBtnTouchUpInside:(UIButton *)sender
{
    
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            [self.recordTool stopRecording];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.hBlock();
            });
        });
}
- (void)recordBtnTouchDragEnter:(UIButton *)sender
{
     NSString * str = @"shang";
    
    NSLog(@"上滑取消");
    self.block(str);
}
- (void)recordBtnTouchDragExit:(UIButton *)sender
{
    NSString * Str = @"canel";
    
     NSLog(@"松手取消");
    
   self.block(Str);
    
}
- (void)recordBtnTouchOutside:(UIButton *)sender
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.recordTool stopRecording];
        [self.recordTool destructionRecordingFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.hBlock();
            
        });
        
    });
}
- (void)beginButtonAction:(UIButton *)sender
{

    [self.recordTool playRecordingFile];
}
- (void)dealloc {
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
}

@end
