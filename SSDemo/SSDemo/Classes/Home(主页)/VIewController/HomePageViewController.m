//
//  HomePageViewController.m
//  SSDemo
//
//  Created by runlhy on 16/2/14.
//  Copyright © 2016年 党政. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomePageCell.h"
#import "ListViewController.h"

@interface HomePageViewController ()

@property (nonatomic, strong) NSArray *classNameArray;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"意语 8000 句";
    
    //regist Cell
    [self.tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:@"HomePageCell"];
    
    //去掉cell 分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initClassName];
}

- (void)initClassName
{
    _classNameArray = @[@"在家中", @"享受余暇时间", @"请医生看病"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _classNameArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageCell" forIndexPath:indexPath];
    
    //连接线逻辑
    if (indexPath.row == 0) {
        cell.upperLineView.hidden = YES;
    }else if(indexPath.row == _classNameArray.count - 1){
        cell.lowerLineView.hidden = YES;
    }else{
        cell.upperLineView.hidden = NO;
        cell.lowerLineView.hidden = NO;
    }
    
    //序号显示
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    
    //课程名称显示
    cell.curriculumLabel.text = _classNameArray[indexPath.row];
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击弹出一个页面
    ListViewController *listViewController = [ListViewController shareListViewController];
    listViewController.lessonNumber = indexPath.row;
    [self.navigationController pushViewController:listViewController animated:YES];
    
}

@end
