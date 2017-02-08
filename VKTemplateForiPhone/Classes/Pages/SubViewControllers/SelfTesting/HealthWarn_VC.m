//
//  SelfTestingViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "HealthWarn_VC.h"
#import "UserSessionCenter.h"
#import "HealthSelfTestPre_VC.h"
@interface HealthWarn_VC ()
@property (nonatomic, assign) NSInteger picNo;
@property (nonatomic, strong) NSArray *data;
@end

@implementation HealthWarn_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"健康预警";
    [self customBackButton];

    if (![app_delegate() checkIfLogin]) {
        [app_delegate() presentLoginViewIn:self];
    }
    
    //examproject-01.png
    [self requestData];
}

- (void)initHealthWarnItems {
    for (NSInteger i=0; i<self.data.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = Screen_Width/2;
        CGFloat height = width/3;
        btn.frame = CGRectMake((Screen_Width - width)/2, height/3 + (height + height/2)*i, width, height);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:_data[i][@"project_title"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"examproject-0%ld.png",_picNo++%9+1]] forState:UIControlStateNormal];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [scView addSubview:btn];
    }
    scView.contentSize = CGSizeMake(scView.frame.size.width, CGRectGetMaxY([scView viewWithTag:self.data.count+99].frame) + 30);
}

#pragma mark - RequestData
- (void)requestData {
    __weakSelf_(weakSelf);
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isValidString([[UserSessionCenter shareSession] getUserId])) {
        [params setObject:[[UserSessionCenter shareSession] getUserId] forKey:@"cur_user_id"];
    }
    if (isValidString(ApplicationDelegate.sessionId)) {
        [params setObject:ApplicationDelegate.sessionId forKey:@"sessionid"];
    }
    
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getExamProjectListByAPP.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            weakSelf.data = [jsonResponse objectForKey:@"rows"];
            [weakSelf initHealthWarnItems];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:NO isCacheNeeded:YES method:nil];
}

#pragma mark - Action
- (void)btnClick:(UIButton *)sender {
    HealthSelfTestPre_VC *vc = [[HealthSelfTestPre_VC alloc] init];
    vc.dic = self.data[sender.tag - 100];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
