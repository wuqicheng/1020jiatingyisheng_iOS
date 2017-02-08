//
//  VIPConsultingViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "VIPConsultingViewController.h"
#import "UserSessionCenter.h"

@interface VIPConsultingViewController () {
    bool isHanlding;
}

@end

@implementation VIPConsultingViewController
@synthesize duration,vipId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"留言";
    [self customBackButton];
    [self customNavigationBarItemWithTitleName:@"提交" isLeft:NO];
    
    labelTips.text = @"注：请您留下您的联系方式和需求，我们的客服人员会及时与您联系.";
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    if (isHanlding) {
        return;
    }
    isHanlding = YES;
    if (tfName.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入您的姓名" cancelButton:String_Sure sureButton:nil];
        return;
    }
    else if (tfPhone.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入您的联系方式" cancelButton:String_Sure sureButton:nil];
        return;
    }
    else if (tvContent.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入留言内容" cancelButton:String_Sure sureButton:nil];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",
                                   tfName.text,@"buy_user_name",
                                   tfPhone.text,@"contact_infos",
                                   tvContent.text,@"msg_content",nil];
    if (isValidString(vipId)) {
        [params setObject:vipId forKey:@"vip_id"];
    }
    if (duration > 0) {
        [params setObject:@(duration) forKey:@"timelength"];
    }
    
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"saveOrUpdateVIPBuyMessageInfos.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"您的留言我们已收到，我们会尽快为您解答."];
            tfPhone.text = @"";
            tfName.text = @"";
            tvContent.text = @"";
            labelPlaceHolder.hidden = YES;
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.f];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
        isHanlding = NO;
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        isHanlding = NO;
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    labelPlaceHolder.hidden = (textView.text.length > 0 || text.length > 0);
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    labelPlaceHolder.hidden = (textView.text.length > 0);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [scView setContentOffset:CGPointMake(0, 100.f) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [scView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
