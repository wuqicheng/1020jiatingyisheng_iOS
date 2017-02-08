//
//  UserCenterViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/2/8.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserCenterViewController.h"
#import "UserSessionCenter.h"
#import "AddressBookViewController.h"
#import "UserPointViewController.h"
#import "WebAppViewController.h"
#import "UserCollectionViewController.h"
#import "ChatListViewController.h"
#import "UserReportViewController.h"
#import "ShareManager.h"
#import "FillInfoViewController.h"
#import "UIImageView+MJWebCache.h"
#import "JPUSHService.h"
#import "ChatBoxViewController.h"
#import "UserHealthWarn_VC.h"
@interface UserCenterViewController () {
    
}
@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![app_delegate() checkIfLogin]) {
        [logout setTitle:@"登陆" forState:UIControlStateNormal];
//        [app_delegate() presentLoginViewIn:self];
//        return;
    }else{
        [logout setTitle:@"退出" forState:UIControlStateNormal];
    }

    [self customBackButton];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitleView:titleView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    app_delegate().tabBarController.title = @"个人中心";
    
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}


#pragma mark - Private
- (void)initView {
    UserSessionCenter *us = [UserSessionCenter shareSession];
    labelUserName.text = [us getUserNickName];
    [imgvAvatar setImageURLStr:[us getUserAvatar] placeholder:Defualt_Avatar_Image];
    imgvAvatar.layer.cornerRadius = imgvAvatar.frame.size.width / 2.f;
    btnCheck.selected = ![us isAutoLoginDisable];
    if ([us isVip]) {
        labelLeftTime.hidden = NO;
        labelLeftTime.text = [NSString stringWithFormat:@"剩余%@天",[us getVipDays]];
        btnVIP.selected = YES;
    }
    else {
        labelLeftTime.hidden = YES;
        btnVIP.selected = NO;
    }
}

#pragma mark - Button Action
- (IBAction)btnAction:(UIButton*)sender {
    if (![app_delegate() checkIfLogin]) {
        if (sender.tag == 200) {
            [app_delegate() presentLoginViewIn:self];
            [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }
    }else{
    if (sender.tag == 200) {
        [self showAlertWithTitle:@"温馨提示" message:@"确定退出?" cancelButton:String_Sure sureButton:String_Cancel tag:(int)sender.tag];
    }
    else if (sender.tag == 300) {
        sender.selected = !sender.selected;
        [[UserSessionCenter shareSession] setAutoLoginDisable:!sender.selected];
    }
        }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [[NSArray alloc] initWithObjects:cell1,cell2,cell3,cell12,cell4,cell5,cell6,cell7,cell9,cell10,cell11, nil];
    if (indexPath.row > arr.count) {
        return nil;
    }
    return [arr objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 90.f;
    }
    else if (indexPath.row == 9) {
        return 50.f;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 7 || indexPath.row == 10) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
    
    if (indexPath.row == 1) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
             [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }

        //个人基本信息
        FillInfoViewController *fVc = [[FillInfoViewController alloc] init];
        [self.navigationController pushViewController:fVc animated:YES];
    }
    else if (indexPath.row == 2) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
             [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }

        //我的收藏
        UserCollectionViewController *cVc = [[UserCollectionViewController alloc] init];
        [self.navigationController pushViewController:cVc animated:YES];
    }
    else if (indexPath.row == 3) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
             [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }

        //我的健康预警
        UserHealthWarn_VC *vc = [[UserHealthWarn_VC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 4) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
             [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }

        //咨询记录
//        ChatListViewController *clVc = [[ChatListViewController alloc] init];
        ChatBoxViewController *clVc = [[ChatBoxViewController alloc] init];
        [self.navigationController pushViewController:clVc animated:YES];
    }
    else if (indexPath.row == 5) {
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
        
        //纠纷投诉
        UserReportViewController *rVc = [[UserReportViewController alloc] init];
        [self.navigationController pushViewController:rVc animated:YES];
    }
    else if (indexPath.row == 6) {
        //检查登录
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
             [logout setTitle:@"退出" forState:UIControlStateNormal];
            return;
        }

        //消费记录
        UserPointViewController *upVc = [[UserPointViewController alloc] init];
        [self.navigationController pushViewController:upVc animated:YES];
    }
    else if (indexPath.row == 8) {
        //关于
        [SVProgressHUD showWithStatus:String_Loading];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getIntroduceList.action" param:nil onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            NSString *desc = @"暂无内容";
            if (isValidArray([jsonResponse objectForKey:@"rows"])) {
                NSDictionary *dic = [[jsonResponse objectForKey:@"rows"] firstObject];
                desc = [dic objectForKey:@"content"];
            }
            WebAppViewController *wVc = [[WebAppViewController alloc] init];
            wVc.htmlContent = desc;
            wVc.title = @"关于";
            [self.navigationController pushViewController:wVc animated:YES];
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (indexPath.row == 9) {
        //分享
//        [[ShareManager shareManeger] presentShareAppDownloadLinkViewIn:self];
        [[ShareManager shareManeger] presentCustomerShareViewIn:self];
    }else if (indexPath.row == 10) {
        //退出
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 200) {
            //注销
            [[UserSessionCenter shareSession] destroyAccountDetailInfo];
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:@"已退出!"];
            [app_delegate().tabBarController setSelectedIndex:0];
            
            ///取消JPush
            [JPUSHService setTags:nil alias:@"" callbackSelector:@selector(setTagsAndAliasCallback) object:nil];
        }
    }
}

- (void)setTagsAndAliasCallback {
    NSLog(@"logout");
}

@end
