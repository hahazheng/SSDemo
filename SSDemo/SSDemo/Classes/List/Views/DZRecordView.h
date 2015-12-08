//
//  DZRecordView.h
//  Senmiao
//
//  Created by lanou3g on 15/11/25.
//  Copyright © 2015年 党政. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^Block) (NSString *name);

typedef void (^HBlock)();


@interface DZRecordView : UIView

+ (instancetype)recordView;



@property (nonatomic,strong) Block block;

@property (nonatomic,strong) HBlock hBlock;



@end
