//
//  RegisterViewController.m
//  aixiche
//
//  Created by Vescky on 14-10-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebAppViewController.h"
#import "UserSessionCenter.h"
#import "AppDelegate.h"
#import "FillInfoViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate> {
    NSString *smsCode;
    int timerCounter;
    bool isPushedDisappear;
    float textfieldBottomY,keyboardHeight;//用于调节scrollview的位置
}
@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [super customBackButton];
    self.title = @"注册";
    //init view
    btnCheckbox.selected = YES;
    tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfPhone.returnKeyType = UIReturnKeyDone;
    tfSMSCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfSMSCode.returnKeyType = UIReturnKeyDone;
    tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfPassword.returnKeyType = UIReturnKeyDone;
    tfComfirmPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfComfirmPassword.returnKeyType = UIReturnKeyDone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isPushedDisappear = NO;
    
    if (scView.frame.size.height < 450) {
        [scView setContentSize:CGSizeMake(scView.frame.size.width, 450)];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!isPushedDisappear) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshTimer) object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)refreshTimer {
    if (timerCounter > 0) {
        timerCounter--;
        [btnSMSCode setTitle:[NSString stringWithFormat:@"重获(%d秒)",timerCounter] forState:UIControlStateDisabled];
        [self performSelector:@selector(refreshTimer) withObject:nil afterDelay:1.0f];
    }
    else {
        btnSMSCode.enabled = YES;
        [btnSMSCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

- (float)getTextfieldBottomY:(int)tTag {
    UIView *tmpView = [scView viewWithTag:1000+tTag];
    if (!tmpView) {
        return 0;
    }
    
    return tmpView.frame.origin.y + tmpView.frame.size.height;
}

- (void)adjustScrollViewPosition {
    float tkMargin = textfieldBottomY + 50 - (self.view.frame.size.height - keyboardHeight);
    if (tkMargin > 0) {
        //textfield超过键盘，即被键盘遮挡了
        [scView setContentOffset:CGPointMake(0, tkMargin) animated:YES];
    }
}

- (bool)checkFormat {
    if (!btnCheckbox.selected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"注册之前，请先阅读并同意注册协议!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (!isValidString(tfPhone.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"手机号码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    if (!isValidString(tfSMSCode.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    if (!isValidString(tfPassword.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    if (!isValidString(tfComfirmPassword.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入确认密码!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (!isMobileNumber(tfPhone.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的号码不正确，请重新输入!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    ///检查验证码是否合法
    if (![[smsCode lowercaseString] isEqualToString:[tfSMSCode.text lowercaseString]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的验证码不正确，请重新输入!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    if (![tfPassword.text isEqualToString:tfComfirmPassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"两次输入的密码不相同，请重新输入!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    NSString *pwdRegex = @"^[a-z0-9A-Z]{4,20}$";
    NSPredicate *pwdPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
    if (![pwdPredicate evaluateWithObject:tfPassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的密码格式不正确!请输入4~20位字母或数字." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

#pragma mark - button action
- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        if (!isMobileNumber(tfPhone.text)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:String_Input_Wrong_Phone delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
        //获取验证码
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tfPhone.text,@"user_phone",@1,@"type",@1,@"user_type", nil];
        [SVProgressHUD showWithStatus:String_Getting_SMSCode];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getPhoneCheckCode.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                if (isValidString([jsonResponse objectForKey:@"code"])) {
                    [SVProgressHUD showSuccessWithStatus:String_SMSCode_Send];
                    smsCode = [jsonResponse objectForKey:@"code"];
                    timerCounter = 60;
                    btnSMSCode.enabled = NO;
                    [self refreshTimer];
                }
                else {
                    [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:@"确定" sureButton:nil];
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:[jsonResponse objectForKey:@"desc"]];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (sender.tag == 101) {
//        注册
        //验证格式
        if (![self checkFormat]) {
            return;
        }
        
        FillInfoViewController *fVc = [[FillInfoViewController alloc] init];
        fVc.phoneNumber = tfPhone.text;
        fVc.psw = tfPassword.text;
        fVc.isRegister = YES;
        [self.navigationController pushViewController:fVc animated:YES];
        return;
        
        ///医生app的注册机制不同，以下代码不执行
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tfPhone.text,@"user_login_name",tfPassword.text,@"user_login_pwd",@1,@"register_type" ,nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"registerToMemberUser.action" param:params onCompletion:^(id jsonResponse) {
            
            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                //注册成功
                [SVProgressHUD showSuccessWithStatus:[jsonResponse objectForKey:@"desc"]];
                [[UserSessionCenter shareSession] savePassword:tfPassword.text];
                [[UserSessionCenter shareSession] saveAccountName:tfPhone.text];
                [ApplicationDelegate loginOnBackground:tfPhone.text password:tfPassword.text];
                //注册成功需要填写资料
                FillInfoViewController *fVc = [[FillInfoViewController alloc] init];
                fVc.userId = getString([jsonResponse objectForKey:@"user_id"]);
                [self.navigationController pushViewController:fVc animated:YES];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:@"确定" sureButton:nil];
            }
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (sender.tag == 102) {
        //登录
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender.tag == 103) {
        //注册协议
        [SVProgressHUD showWithStatus:String_Loading];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@1,@"type", nil];
        [[AppsNetWorkEngine shareEngine] submitRequest:@"getRegisterAgreeList.action" param:params onCompletion:^(id jsonResponse) {
            [SVProgressHUD dismiss];
            NSString *desc = @"暂无内容";
            if (isValidArray([jsonResponse objectForKey:@"rows"])) {
                NSDictionary *dic = [[jsonResponse objectForKey:@"rows"] firstObject];
                desc = [dic objectForKey:@"content"];
            }
            
            WebAppViewController *wVc = [[WebAppViewController alloc] init];
            wVc.htmlContent = desc;
            wVc.title = @"用户服务协议";
            [self.navigationController pushViewController:wVc animated:YES];
            isPushedDisappear = YES;
        } onError:^(NSError *error) {
            [SVProgressHUD dismiss];
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
        
    }
    else if (sender.tag == 104) {
        //checkbox
        btnCheckbox.selected = !btnCheckbox.selected;
    }
}

#pragma mark - over-write
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardHeight = keyboardRect.size.height;
    [self adjustScrollViewPosition];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textfieldBottomY = [self getTextfieldBottomY:textField.tag];
    [self adjustScrollViewPosition];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [scView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end