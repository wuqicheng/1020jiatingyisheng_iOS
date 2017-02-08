//
//  NewRelationShipViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NewRelationShipViewController.h"
#import "UserSessionCenter.h"

@interface NewRelationShipViewController ()<UITextFieldDelegate> {
    
}
@end

@implementation NewRelationShipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加亲人";
    [self customBackButton];
    [self customNavigationBarItemWithTitleName:@"确定" isLeft:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    [tfPhone resignFirstResponder];
    if (tfPhone.text.length > 11 || tfPhone.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"请输入正确的手机号码" cancelButton:String_Sure sureButton:nil];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在发送申请..."];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tfPhone.text,@"user_phone",[[UserSessionCenter shareSession] getUserId],@"user_id", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"sendApplyForFamily.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"申请已发出！"];
            tfPhone.text = @"";
            labelName.text = @"";
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@-%@",textField.text,string);
    NSString *phoneNum = [textField.text stringByAppendingString:string];
    if (phoneNum.length == 11) {
        [self queryUserNickNameForPhone:phoneNum];
    }
    else {
        labelName.text = @"";
    }
    return YES;
}


#pragma mark - Data
- (void)queryUserNickNameForPhone:(NSString*)phone {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:phone,@"user_phone", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getUserNameByPhone.action" param:params onCompletion:^(id jsonResponse) {
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            labelName.text = [jsonResponse objectForKey:@"user_nick"];
        }
        else {
            labelName.text = [jsonResponse objectForKey:@"desc"];
        }
    } onError:^(NSError *error) {
        
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

@end
