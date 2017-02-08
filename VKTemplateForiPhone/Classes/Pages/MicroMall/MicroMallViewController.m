//
//  MicroMallViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MicroMallViewController.h"

@interface MicroMallViewController ()

@end

@implementation MicroMallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"微信商城";
    scView.contentSize = CGSizeMake(scView.frame.size.width, 550.f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    app_delegate().tabBarController.title = @"微信商城";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}


@end
