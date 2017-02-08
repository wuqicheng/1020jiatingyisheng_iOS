//
//  ExampleViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/29.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleViewController : UIViewController

- (instancetype)initWithIndex:(NSInteger)index title:(NSString *)title;

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *desc1Array;
@property(null_resettable,copy) NSAttributedString *attributedText NS_AVAILABLE_IOS(6_0);
@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)stopRefreshing;

@end
