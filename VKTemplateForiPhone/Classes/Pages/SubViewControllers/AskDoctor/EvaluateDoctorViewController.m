//
//  EvaluateDoctorViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EvaluateDoctorViewController.h"
#import "UserSessionCenter.h"


@interface EvaluateDoctorViewController ()
{
    bool isEvalua;
}
@end

@implementation EvaluateDoctorViewController
//@synthesize detailInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    self.title = @"评价";
    self.view.backgroundColor = [UIColor whiteColor];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self chectEvaluaType];
}

//检查评论的类型
-(void)chectEvaluaType
{
    if (isValidString(self.phoneCallId)) {
        isEvalua = YES;
        NSLog(@"%@ is not null",_phoneCallId);
    }
    else
    {
        isEvalua = NO;
         NSLog(@"2222");
    }
}


- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        if (isEvalua) {
            [self submitPhoneCallEvaluate];
        }
        else
        {
        [self submitSingleChatEvaluate];
        NSLog(@"2222");
        }
    }
}

//图文咨询评价
- (void)submitSingleChatEvaluate {
    if (tvContent.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入评价内容" cancelButton:@"好的" sureButton:nil];
        return;
    }
    NSInteger rate1 = rateView1.rating;
    NSInteger rate2 = rateView2.rating;
    
    if (rate1 <= 0) {
        [self showAlertWithTitle:nil message:@"请评价服务态度" cancelButton:@"好的" sureButton:nil];
        return;
    }
    if (rate2 <= 0) {
        [self showAlertWithTitle:nil message:@"请评价医生水平" cancelButton:@"好的" sureButton:nil];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   tvContent.text,@"comment_msg",
                                   @(rate1),@"attitude_star",
                                   @(rate2),@"ability_star",
                                   [[UserSessionCenter shareSession] getUserId],@"cs_user_id",
                                   self.conversationId,@"conversation_id", nil];
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"commitUserCommentSession.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([jsonResponse objectForKey:@"status"]) {
            [SVProgressHUD showSuccessWithStatus:@"评价成功!"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.f];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    
}

//电话咨询评价
-(void)submitPhoneCallEvaluate
{
    if (tvContent.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入评价内容" cancelButton:@"好的" sureButton:nil];
        return;
    }
    NSInteger rate1 = rateView1.rating;
    NSInteger rate2 = rateView2.rating;
    
    if (rate1 <= 0) {
        [self showAlertWithTitle:nil message:@"请评价服务态度" cancelButton:@"好的" sureButton:nil];
        return;
    }
    if (rate2 <= 0) {
        [self showAlertWithTitle:nil message:@"请评价医生水平" cancelButton:@"好的" sureButton:nil];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   tvContent.text,@"comment_msg",
                                   @(rate1),@"attitude_star",
                                   @(rate2),@"ability_star",
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",
                                   self.phoneCallId,@"phone_conversation_id", nil];
    [SVProgressHUD showWithStatus:String_Submitting];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"commitUserPhoneCommentSession.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([jsonResponse objectForKey:@"status"]) {
            [SVProgressHUD showSuccessWithStatus:@"评价成功!"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.f];
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
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

@end
