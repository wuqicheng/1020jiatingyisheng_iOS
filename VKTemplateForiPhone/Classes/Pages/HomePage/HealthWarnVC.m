//
//  HealthWarnVC.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/29.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "HealthWarnVC.h"
#import "SegmentViewController.h"
#import "ExampleViewController.h"
#import "UserSessionCenter.h"
#import "MJRefresh.h"

static CGFloat const ButtonHeight = 50;

@interface HealthWarnVC ()<meDelegateViewController,MJRefreshBaseViewDelegate>{
    NSInteger pageLevel;
    SegmentViewController *_SVC;
}

@end

@implementation HealthWarnVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    _dataSource1 = [[NSMutableArray alloc] init];
    _dataSource2 = [[NSMutableArray alloc] init];
    self.title = @"健康预警";
    [self requestData];
}

//实现代理delegate；
- (void)didSelectSegmentIndex:(NSInteger)index{
    _selectedIndex = index-10000;
  
    __weakSelf_(weakSelf);
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
}

- (void)initHealthWarnItems {
    [self customBackButton];
    UIBarButtonItem *bItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[bItem];
    
      __weakSelf_(weakSelf);
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
    }
    
- (void)initItems{
    _SVC = [[SegmentViewController alloc]init];
    _SVC.delegate = self;
    NSMutableArray *_parentTitleArray = [[NSMutableArray alloc]init];
    _parentTitleArray = [_dataSource1 valueForKey:@"name"];
    _SVC.titleArray = _parentTitleArray;
    [_SVC addParentController:self];
    NSMutableArray *controlArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < _dataSource1.count; i ++) {
        ExampleViewController *_EVC = [[ExampleViewController alloc]initWithIndex:i title:_SVC.titleArray[i]];
        _EVC.dataSource = [[NSMutableArray alloc]init];
        [_EVC.dataSource addObjectsFromArray:_dataSource2];
        [controlArray addObject:_EVC];
    }
    _SVC.titleSelectedColor = [UIColor colorWithRed:50.0/255.0 green:209.0/255.0 blue:104.0/255.0 alpha:1.0];
    _SVC.subViewControllers = controlArray;
    _SVC.buttonWidth = 80;
    _SVC.buttonHeight = ButtonHeight;
    _SVC.selectIndex0 = self.selectedIndex;
   [_SVC initSegment];
   }

#pragma mark - Data
- (void)refreshData {
    _page = 1;
    _dataSource1 = [[NSMutableArray alloc] init];
    _dataSource2 = [[NSMutableArray alloc] init];
    __weakSelf_(weakSelf);
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
}

//need to over write
- (void)loadMoreData  {
    _page++;
    __weakSelf_(weakSelf);
    [self requestMedicalProjectWithDepartId:nil targetTitle:nil page:1 block:^(BOOL index, NSArray *arr) {
        [weakSelf.allMedicalProjectList addObjectsFromArray:arr];
    }];
}

#pragma mark 加载返回按钮
- (void)customBackButton {
    //自定义背景图片
    UIImage* image= [UIImage imageNamed:@"back.png"];
    CGRect frame_1= CGRectMake(0, 0, 20, 44);
    UIView *cView = [[UIView alloc] initWithFrame:frame_1];
    
    //自定义按钮图片
    UIImageView *cImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 11, 20)];
    [cImgView setImage:image];
    [cView addSubview:cImgView];
    
    //覆盖一个大按钮在上面，利于用户点击
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [cView addSubview:backButton];
    
    //创建导航栏按钮UIBarButtonItem
    UIBarButtonItem* backItem= [[UIBarButtonItem alloc] initWithCustomView:cView];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)requestData {
    __weakSelf_(weakSelf);
//    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamProjectTypeList.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
           NSArray *arr = [jsonResponse objectForKey:@"rows"];NSLog(@"&&&%@**1*&&&",arr);
            if (isValidArray(arr)) {
                [_dataSource1 removeAllObjects];
                [_dataSource1 addObjectsFromArray:arr];
                [weakSelf initHealthWarnItems];
                [weakSelf showNoData:NO];
            }else {
                [weakSelf showNoData:YES];
            }
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

//加载列表信息接口
- (void)requestMedicalProjectWithDepartId:(NSString *)departId targetTitle:(NSString *)targetTitle page:(NSInteger)page block:(void(^)(BOOL, NSArray *))block {
    __weakSelf_(weakSelf);
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f];
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:@[departId?departId:@"", targetTitle?[targetTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@""] forKeys:@[@"hospital_depart_id", @"target_title"]];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    NSMutableArray *idArray = [[NSMutableArray alloc]init];
    idArray = [_dataSource1 valueForKey:@"id"];
    [params setValue:idArray[_selectedIndex] forKey:@"type_id"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
      [params setObject:@(1000) forKey:@"rows"];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamProjectListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *arr = [jsonResponse objectForKey:@"rows"];
            if (jsonResponse[@"remain_page"] && [[NSString stringWithFormat:@"%@", jsonResponse[@"remain_page"]] integerValue] == 0) {
                weakSelf.isLastPage = YES;
            }else {
                weakSelf.isLastPage = NO;
            }
            if (isValidArray(arr)) {
                block(weakSelf.isLastPage, arr);
                if (page == 1) {
                    [_dataSource2 removeAllObjects];
                }
                [_dataSource2 addObjectsFromArray:arr];
                    [self initItems];
                [weakSelf showNoData:NO];
            }else {
                [_dataSource2 removeAllObjects];
                 [self initItems];
                [weakSelf showNoData:YES];
            }
        }
    } onError:^(NSError *error) {
        [weakSelf showNoData:YES];
        [SVProgressHUD dismiss];
        [weakSelf stopRefreshing];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end