//
//  VIPPageViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "VIPPageViewController.h"
#import "VIPPaymentViewController.h"
#import "UserSessionCenter.h"
@interface VIPPageViewController () {
    
}

@end

@implementation VIPPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"立即购买";
    [self customBackButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UserSessionCenter shareSession] isVip]) {
        labelTitle.text = @"您的服务时长";
//        labelTitle.text = [NSString stringWithFormat:@"您的%@VIP特权",[[UserSessionCenter shareSession] getVipLevelName]];
        labelDays.text = [[UserSessionCenter shareSession] getVipDays];
        [btnBuy setTitle:@"继续购买" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton*)sender {
    //检查登陆
    if (sender.tag == 204 || sender.tag == 207 || sender.tag == 208) {
        if (![app_delegate() checkIfLogin]) {
            [app_delegate() presentLoginViewIn:self];
            return;
        }
    }
    
    VIPPaymentViewController *pVc = [[VIPPaymentViewController alloc] init];
    [self.navigationController pushViewController:pVc animated:YES];
}

@end
