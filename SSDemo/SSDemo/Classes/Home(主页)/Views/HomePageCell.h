//
//  HomePageCell.h
//  SSDemo
//
//  Created by runlhy on 16/2/14.
//  Copyright © 2016年 党政. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *upperLineView;
@property (weak, nonatomic) IBOutlet UIView *lowerLineView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *curriculumLabel;

@end
