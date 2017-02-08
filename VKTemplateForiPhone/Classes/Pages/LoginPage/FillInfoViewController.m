//
//  FillInfoViewController.m
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/2/13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "FillInfoViewController.h"
#import "UIImageView+MJWebCache.h"
#import "UserSessionCenter.h"
#import "PickDateTimeActionSheetView.h"
#import "MyActionSheetView.h"
#import "PickAddressActionSheetView.h"

//#define UsingAlertInput

@interface FillInfoViewController ()<PickDateTimeActionSheetViewDelegate,MyActionSheetViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,PickAddressActionSheetViewDelegate> {
    NSString *avatarLink;
    CGFloat keyboardHeight,textfieldBottomY;
    PickDateTimeActionSheetView *datePicker;
    MyActionSheetView *photoPicker;
    PickAddressActionSheetView *addressPicker;
}

@end

@implementation FillInfoViewController
@synthesize phoneNumber,userId,psw,isRegister;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (isRegister) {
        self.title = @"填写资料";
    }
    else {
        self.title = @"个人基本信息";
        avatarLink = [[UserSessionCenter shareSession] getUserAvatar];
    }
    
    [self customBackButton];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    NSString *tips = @"提示：为了防止个人隐私泄漏，同时保证医生诊断时对您基本健康信息的准确了解，建议注册时用昵称代替您真实姓名，也不要上传个人真实照片，但其它信息务请真实准确填写，住址须细化到区县";
    labelTips.text = tips;
    setViewFrameOriginY(labelTips, tbView.frame.origin.y+tbView.frame.size.height+5.f);
    fitLabelHeight(labelTips, tips);
    setViewFrameOriginY(btnSure, labelTips.frame.origin.y+labelTips.frame.size.height+5.f);
    
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2.f;
    imgAvatar.clipsToBounds = YES;
    
    scView.contentSize = CGSizeMake(scView.frame.size.width, btnSure.frame.origin.y+btnSure.frame.size.height+20.f);
    
    datePicker = [[PickDateTimeActionSheetView alloc] initWithTitle:@"选择生日" pickerType:PickDateTimeActionSheetViewTypePickDateOnly];
    datePicker.picker.maximumDate = [NSDate date];
    datePicker.delegate = self;
    
    photoPicker = [[MyActionSheetView alloc] initWithPhotoSelectorStyle];
    photoPicker.delegate = self;
    
    addressPicker = [[PickAddressActionSheetView alloc] initWithTitle:@"选择省市" pickerType:PickAddressActionSheetViewTypeDefault];
    addressPicker.delegate = self;
    
    [self initData];
}

- (void)initData {
    if (!isValidString(userId)) {
        userId = [[UserSessionCenter shareSession] getUserId];
    }
    
    NSDictionary *detailInfo = [[UserSessionCenter shareSession] getAccountDetailInfo];
    if (isValidDictionary(detailInfo)) {
        //初始化表格
        [imgAvatar setImageURLStr:[detailInfo objectForKey:@"photo"] placeholder:nil];
        tfUserNick.text = [detailInfo objectForKey:@"user_nick"];
        tfWechatNo.text = [detailInfo objectForKey:@"wechat"];
        tfEmail.text = [detailInfo objectForKey:@"email"];
        tfName.text = [detailInfo objectForKey:@"contact_person"];
        tfPhoneNum.text = [detailInfo objectForKey:@"contact_person_phone"];
        
        if ([[detailInfo objectForKey:@"sex"] integerValue] == 1) {
            checkboxMale.selected = YES;
            checkboxFemale.selected = NO;
        }
        else {
            checkboxMale.selected = NO;
            checkboxFemale.selected = YES;
        }
        
        NSString *dStr =  [detailInfo objectForKey:@"birth_date"];
        labelBirthday.text = [[dStr componentsSeparatedByString:@" "] firstObject];
        datePicker.selectedDate = getDateFromString(@"yyyy-MM-dd", [detailInfo objectForKey:@"birth_date"]);
        labelAddress.text = [detailInfo objectForKey:@"distincts"];
    }
}

- (bool)checkFormat {
//    if (avatarLink.length <= 0) {
//        [self showAlertWithTitle:nil message:@"头像不能为空" cancelButton:String_Sure sureButton:nil];
//        return NO;
//    }
    if (tfUserNick.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"昵称不能为空" cancelButton:String_Sure sureButton:nil];
        return NO;
    }
    if (labelBirthday.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"出生日期不能为空" cancelButton:String_Sure sureButton:nil];
        return NO;
    }
    if (labelAddress.text.length <= 0) {
        [self showAlertWithTitle:nil message:@"地址不能为空" cancelButton:String_Sure sureButton:nil];
        return NO;
    }
//    if (tfWechatNo.text.length <= 0) {
//        [self showAlertWithTitle:nil message:@"微信号不能为空" cancelButton:String_Sure sureButton:nil];
//        return NO;
//    }
    return YES;
}

//是否有修改
- (bool)hasModified {
    if (avatarLink.length > 0 || tfUserNick.text.length > 0 || labelBirthday.text.length > 0 || labelAddress.text.length > 0 || tfWechatNo.text.length > 0 || tfEmail.text.length > 0 || tfName.text.length > 0 || tfPhoneNum.text.length > 0) {
        if (isRegister) {
            return YES;
        }
        else {
            NSDictionary *detailInfo = [[UserSessionCenter shareSession] getAccountDetailInfo];
            NSString *bthString = [[[detailInfo objectForKey:@"birth_date"] componentsSeparatedByString:@" "] firstObject];
            if (avatarLink.length > 0 || ![tfUserNick.text isEqualToString:[detailInfo objectForKey:@"user_nick"]] ||
                !([[detailInfo objectForKey:@"sex"] integerValue] == checkboxMale.selected) ||
                ![labelBirthday.text isEqualToString:bthString] ||
                ![labelAddress.text isEqualToString:[detailInfo objectForKey:@"distincts"]] ||
                ![tfWechatNo.text isEqualToString:[detailInfo objectForKey:@"wechat"]] ||
                ![tfEmail.text isEqualToString:[detailInfo objectForKey:@"email"]] ||
                ![tfPhoneNum.text isEqualToString:[detailInfo objectForKey:@"contact_person_phone"]] ||
                ![tfName.text isEqualToString:[detailInfo objectForKey:@"contact_person"]]) {
                
                return YES;
            }
        }
    }
    return NO;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
    
//    [self dismissKeyboard];
//    if ([self hasModified]) {
//        [self showAlertWithTitle:@"提示" message:@"您编辑的信息尚未保存，离开此页内容将丢失。" cancelButton:@"离开" sureButton:@"留下" tag:999];
//    }
//    else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)dismissKeyboard {
    [tfEmail resignFirstResponder];
    [tfName resignFirstResponder];
    [tfPhoneNum resignFirstResponder];
    [tfUserNick resignFirstResponder];
    [tfWechatNo resignFirstResponder];
}

- (void)submitUpdate {
    if (![self checkFormat]) {
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   checkboxFemale.selected ? @2 : @1,@"sex",nil];
    
    if (isValidString(avatarLink)) {
        [params setObject:avatarLink forKey:@"photo"];
    }
    
    if (isValidString(tfUserNick.text)) {
        [params setObject:tfUserNick.text forKey:@"user_nick"];
    }
    
    if (isValidString(labelBirthday.text)) {
        [params setObject:labelBirthday.text forKey:@"birth_date"];
    }
    
    if (isValidString(labelAddress.text)) {
        [params setObject:labelAddress.text forKey:@"distincts"];
    }
    
    if (isValidString(tfWechatNo.text)) {
        [params setObject:tfWechatNo.text forKey:@"wechat"];
    }
    
    if (isValidString(phoneNumber)) {
        [params setObject:phoneNumber forKey:@"user_login_name"];
    }
    
    if (isValidString(psw)) {
        [params setObject:psw forKey:@"user_login_pwd"];
    }
    
    if (tfEmail.text.length > 0) {
        [params setObject:tfEmail.text forKey:@"email"];
    }
    
    if (tfName.text.length > 0) {
        [params setObject:tfName.text forKey:@"contact_person"];
    }
    
    if (tfPhoneNum.text.length > 0) {
        [params setObject:tfPhoneNum.text forKey:@"contact_person_phone"];
    }
    
    if (userId) {
        [params setObject:userId forKey:@"user_id"];
    }
    
    [SVProgressHUD showWithStatus:String_Saving];
    //提交资料
    [[AppsNetWorkEngine shareEngine] submitRequest:@"improveUserInfos.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            //            [[UserSessionCenter shareSession] savePassword:psw];
            //            [[UserSessionCenter shareSession] saveAccountName:phoneNumber];
            [[UserSessionCenter shareSession] saveUserAvatar:avatarLink];
            [[UserSessionCenter shareSession] saveUserNickName:tfUserNick.text];
            
            [ApplicationDelegate loginOnBackground:phoneNumber password:psw];
            
            if (isRegister) {
                [SVProgressHUD showSuccessWithStatus:@"注册成功!"];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    //back to main view
                }];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:[jsonResponse objectForKey:@"desc"]];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        [self submitUpdate];
    }
    else if (sender.tag == 101) {
        //male
        checkboxMale.selected = YES;
        checkboxFemale.selected = NO;
    }
    else if (sender.tag == 102) {
        //female
        checkboxMale.selected = NO;
        checkboxFemale.selected = YES;
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [[NSArray alloc] initWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8,cell9, nil];
    if (indexPath.row > arr.count) {
        return nil;
    }
    
    UITableViewCell *cell = [arr objectAtIndex:indexPath.row];
    if ([cell respondsToSelector:@selector(addSubview:)]) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1.f, cell.frame.size.width, 1.f)];
        line.backgroundColor = GetColorWithRGB(240, 240, 240);
        [cell.contentView addSubview:line];
    }
    
    if (indexPath.row == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 65.f;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        //头像
        [self dismissKeyboard];
        [photoPicker show];
    }
    else if (indexPath.row == 3) {
        //生日
        [self dismissKeyboard];
        [datePicker show];
    }
    else if (indexPath.row == 4) {
        //地址
        [self dismissKeyboard];
        [addressPicker show];
    }
    else {
#ifdef UsingAlertInput
        NSString *alertTitle,*alertContent;
        if (indexPath.row == 1) {
            //昵称
            alertTitle = @"请输入昵称";
            alertContent = labelNickName.text;
        }
        else if (indexPath.row == 5) {
            //微信号
            alertTitle = @"请输入微信号";
            alertContent = labelWechatNo.text;
        }
        else if (indexPath.row == 6) {
            //邮箱
            alertTitle = @"请输入邮箱";
            alertContent = labelEmail.text;
        }
        else if (indexPath.row == 7) {
            //联系人姓名
            alertTitle = @"请输入联系人姓名";
            alertContent = labelName.text;
        }
        else if (indexPath.row == 8) {
            //联系人电话
            alertTitle = @"请输入联系人电话";
            alertContent = labelPhoneNum.text;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:String_Cancel otherButtonTitles:String_Sure, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = indexPath.row + 100;
        [alert show];
        
        UITextField *tfTmp = [alert textFieldAtIndex:0];
        tfTmp.text = alertContent;
        if (indexPath.row == 8) {
            //联系人电话
            tfTmp.keyboardType = UIKeyboardTypePhonePad;
        }
#endif
        switch (indexPath.row) {
            case 1://昵称
                [tfUserNick becomeFirstResponder];
                break;
            case 5://微信号
                [tfWechatNo becomeFirstResponder];
                break;
            case 6://邮箱
                [tfEmail becomeFirstResponder];
                break;
            case 7://联系人姓名
                [tfName becomeFirstResponder];
                break;
            case 8://联系人电话
                [tfPhoneNum becomeFirstResponder];
                break;
                
            default:
                break;
        }
    }
}

#ifdef UsingAlertInput
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *tfTmp = [alertView textFieldAtIndex:0];
        switch (alertView.tag) {
            case 101:
                //昵称
                labelNickName.text = tfTmp.text;
                break;
            case 105:
                //微信号
                labelWechatNo.text = tfTmp.text;
                break;
            case 106:
                //邮箱
                labelEmail.text = tfTmp.text;
                break;
            case 107:
                //联系人姓名
                labelName.text = tfTmp.text;
                break;
            case 108:
                //联系人电话
                labelPhoneNum.text = tfTmp.text;
                break;
            default:
                break;
        }
    }
}
#endif

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
    textfieldBottomY = (textField.tag+1)*44.f;
    [self adjustScrollViewPosition];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [scView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)adjustScrollViewPosition {
    float tkMargin = textfieldBottomY + 50 - (self.view.frame.size.height - keyboardHeight);
    if (tkMargin > 0) {
        //textfield超过键盘，即被键盘遮挡了
        [scView setContentOffset:CGPointMake(0, tkMargin) animated:YES];
    }
}

#pragma mark - PickDateTimeActionSheetViewDelegate
- (void)pickDateTimeActionSheetView:(PickDateTimeActionSheetView*)sheetView didSelectedDateTime:(NSDate*)sDate {
    //选择了日期
    if (sDate) {
        labelBirthday.text = getStringFromDate(@"yyyy-MM-dd", sDate);
    }
}

#pragma mark - MyActionSheetViewDelegate
- (void)btnDidClick:(int)buttonIndex {
    if (buttonIndex == 1) {
        //拍摄
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;  //是否可编辑
            //摄像头
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{
                NSLog(@"get picture");
            }];
        }else{
            //如果没有提示用户
            [SVProgressHUD showErrorWithStatus:String_Device_Not_Supported_Camera];
        }
    }
    else if (buttonIndex == 2) {
        //相册
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;  //是否可编辑
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
            NSLog(@"get picture");
        }];
    }
}

#pragma mark  - PickAddressActionSheetViewDelegate
- (void)pickAddressActionSheetView:(PickAddressActionSheetView*)pv didSelectAddress:(PickAddressItem*)address {
    if (address) {
        labelAddress.text = [NSString stringWithFormat:@"%@%@%@",address.provinceName,address.cityName,address.districtName];
    }
}

#pragma mark - UINavigationControllerDelegate,UIImagePickerControllerDelegate
//拍摄完成后要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //得到图片
    __block UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *savePath = saveAndResizeImage(image, [NSString stringWithFormat:@"tmp_image_%@.png",getStringFromDate(@"yyyyMMddHHmmss", [NSDate date])],300);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"正在上传图片..."];
            [[AppsNetWorkEngine shareEngine] uploadImagePath:savePath onCompletion:^(id jsonResponse) {
                [SVProgressHUD dismiss];
                if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                    [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
                    avatarLink = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"message"];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            } onError:^(NSError *error) {
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        });
        
    });
    
    [imgAvatar setImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to main vc.");
        [tbView reloadData];
    }];
}

//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back to main vc.");
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 999) {
            //回退
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end