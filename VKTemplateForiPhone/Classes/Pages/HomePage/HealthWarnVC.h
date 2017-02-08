//
//  HealthWarnVC.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/29.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface HealthWarnVC : AppsBaseViewController

@property (nonatomic, strong) NSMutableArray *dataSource1;
@property (nonatomic, strong) NSMutableArray *dataSource2;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *allMedicalProjectList;
@property (nonatomic, strong) NSMutableArray *projectTitleArray;
@property (nonatomic ,assign) NSInteger selectedIndex;

- (void)stopRefreshing;
- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block;

@end
