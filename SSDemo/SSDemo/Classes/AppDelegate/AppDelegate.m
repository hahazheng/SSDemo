//
//  AppDelegate.m
//  SSDemo
//
//  Created by lanou3g on 15/12/5.
//  Copyright © 2015年 党政. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerHelper.h"
#import "ListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //开始接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //结束接受远程事件
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



//重写父类方法 处理点击事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlStop:{
                NSLog(@"停止事件");
            }
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:{
                //线控播放
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                if ([PlayerHelper sharePlayerHelper].isPlay) {
                    [[ListViewController shareListViewController] pauseMusic];
                }else{
                    [[ListViewController shareListViewController] playMusic];
                }
            }
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:{
                //上一曲 以及耳机点击三次
                NSLog(@"上一曲");
                [[ListViewController shareListViewController] PreviousMusic];
            }
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:{
                //下一曲 以及耳机点击二次
                NSLog(@"下一曲");
                [[ListViewController shareListViewController] nextMusic];
            }
                break;
                
            case UIEventSubtypeRemoteControlPlay:{
                NSLog(@"UIEventSubtypeRemoteControlPlay");
                [[ListViewController shareListViewController] playMusic];
            }
                break;
                
            case UIEventSubtypeRemoteControlPause:{
                //后台暂停
                NSLog(@"UIEventSubtypeRemoteControlPause");
                [[ListViewController shareListViewController] pauseMusic];
            }
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:{
                NSLog(@"快退开始");
            }
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:{
                NSLog(@"快退结束");
            }
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:{
                NSLog(@"快进开始");
            }
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:{
                NSLog(@"快进结束");
            }
                break;
                
            default:
                break;
        }
    }
}

@end
