//
//  LoginPageViewController.m
//  aixiche
//
//  Created by vescky.luo on 14-10-5.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "LoginPageViewController.h"
#import "RegisterViewController.h"
#import "ResetPasswordViewController.h"
#import "AppsLocationManager.h"
#import "UserSessionCenter.h"
#import <QuartzCore/QuartzCore.h>
#import "JPUSHService.h"

@interface LoginPageViewController ()<UITextFieldDelegate>

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    [super customBackButton];
    [self customNavigationBarItemWithTitleName:@"注册" isLeft:NO];
    [self initView];
    
    if ([[UserSessionCenter shareSession] isAutoFillAccountInfo]) {
        tfPhone.text = [[UserSessionCenter shareSession] getAccountName];
        tfPassword.text = [[UserSessionCenter shareSession] getUserPassword];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    viewForPassword.layer.cornerRadius = 5.0;
    viewForPhone.layer.cornerRadius = 5.0;
    btnLogin.layer.cornerRadius = 3.0;
    
    tfPassword.returnKeyType = UIReturnKeyDone;
    tfPhone.returnKeyType = UIReturnKeyDone;
    
    tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    if ([[UserSessionCenter shareSession] getAccountName]) {
        tfPhone.text = [[UserSessionCenter shareSession] getAccountName];
        
        if ([[UserSessionCenter shareSession] getUserPassword]) {
            tfPassword.text = [[UserSessionCenter shareSession] getUserPassword];
        }
    }
}

- (void)goBack {
        [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to main vc");
    }];
}

- (void)rightBarButtonAction {
    RegisterViewController *rgVc = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:rgVc animated:YES];
}

- (bool)checkFormat {
    if (!isValidString(tfPhone.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"手机号码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    if (!isValidString(tfPassword.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (!isMobileNumber(tfPhone.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的号码不正确，请重新输入!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    NSString *pwdRegex = @"^[a-z0-9A-Z]{4,20}$";
    NSPredicate *pwdPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pwdRegex];
    if (![pwdPredicate evaluateWithObject:tfPassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的密码格式不正确!请输入4~20位字母或数字." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)setTagsAndAliasCallback {
    
}

- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        //登录
        if (![self checkFormat]) {
            return;
        }
        NSString *latStr = [NSString stringWithFormat:@"%lf",[[[AppsLocationManager sharedManager] currentLocation] coordinate].latitude];
        NSString *lonStr = [NSString stringWithFormat:@"%lf",[[[AppsLocationManager sharedManager] currentLocation] coordinate].longitude];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tfPhone.text,@"user_login_name",tfPassword.text,@"user_login_pwd",@2,@"plat_type",lonStr,@"earth_x",latStr,@"earth_y",@0,@"earth_z",@"anonymous",@"token", nil];
        NSLog(@"%@",params);
        [SVProgressHUD showWithStatus:String_LoggingIn];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"appCLoginToSystem.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                //登录成功
                [SVProgressHUD showSuccessWithStatus:[jsonResponse objectForKey:@"desc"]];
                [[UserSessionCenter shareSession] setAutoFillAccountInfo:btnCheckBox.isSelected];//是否记住密码
                [[UserSessionCenter shareSession] savePassword:tfPassword.text];
                [[UserSessionCenter shareSession] saveAccountName:tfPhone.text];
                [[UserSessionCenter shareSession] saveAccountDetailInfo:[jsonResponse objectForKey:@"resultInfos"]];//保存用户信息
                ApplicationDelegate.sessionId = [jsonResponse objectForKey:@"sessionid"];
                //注册用户的JPush别名
                [JPUSHService setTags:nil alias:[[[UserSessionCenter shareSession] getAccountDetailInfo] objectForKey:@"user_code"] callbackSelector:@selector(setTagsAndAliasCallback) object:nil];
                
                
                
                NSLog(@"setalias:%@",[[[UserSessionCenter shareSession] getAccountDetailInfo] objectForKey:@"user_code"]);
                //登录成功通知
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Login_Success object:nil];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"back to main vc");
                }];
            }
            else  {//if ([[jsonResponse objectForKey:@"status"] intValue] == 1)
                [SVProgressHUD showErrorWithStatus:[jsonResponse objectForKey:@"desc"]];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (sender.tag == 101) {
        //忘记密码
        ResetPasswordViewController *resetVc = [[ResetPasswordViewController alloc] init];
        [self.navigationController pushViewController:resetVc animated:YES];
    }
    else if (sender.tag == 102) {
        //记住密码
        btnCheckBox.selected = !btnCheckBox.selected;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
