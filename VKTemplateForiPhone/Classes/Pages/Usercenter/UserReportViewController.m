//
//  UserReportViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "UserReportViewController.h"
#import "UserSessionCenter.h"

@interface UserReportViewController ()<UITextViewDelegate> {
    
}
@end

@implementation UserReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"纠纷投诉";
    [self customBackButton];
    [self customNavigationBarItemWithTitleName:@"提交" isLeft:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    
    if (tvContent.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入内容" cancelButton:String_Sure sureButton:nil];
        return;
    }
    [tvContent resignFirstResponder];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",tvContent.text,@"dispute_content", nil];
    
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"saveOrUpdateDisputeRecordInfos.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [self showAlertWithTitle:nil message:@"您的反馈我们已收到，我们会尽快为您处理" cancelButton:@"好的" sureButton:nil tag:100];
            tvContent.text = @"";
            labelPlaceHolder.hidden = NO;
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        labelPlaceHolder.hidden = YES;
    }
    else {
        labelPlaceHolder.hidden = NO;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
