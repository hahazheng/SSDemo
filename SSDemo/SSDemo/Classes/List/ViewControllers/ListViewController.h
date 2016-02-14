//
//  ListViewController.h
//  Senmiao
//
//  Created by lanou3g on 15/11/23.
//  Copyright © 2015年 党政. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController
//外界接口
@property (nonatomic, copy) NSString *mp3Url;
@property (nonatomic, copy) NSString *lrcUrl;
@property (nonatomic, assign) NSInteger lessonNumber;
@property (nonatomic, assign) NSInteger curretnLenssonNumber;
#pragma mark - 单例方法
+ (instancetype) shareListViewController;

- (void)pauseMusic;
- (void)playMusic;
- (void)PreviousMusic;
- (void)nextMusic;


@end
