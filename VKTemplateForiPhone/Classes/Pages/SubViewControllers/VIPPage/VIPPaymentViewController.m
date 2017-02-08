//
//  VIPPaymentViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
//one_year: 0,
//two_year: 0,
//buy_cfg_id: 3,
//three_year: 0,
//status: 0,
//delflag: 0,
//last_update_date: 2015-06-01 12:01:37,
//vip_id: 3,
//six_month: 200,
//vip_name: 钻石卡,


#import "VIPPaymentViewController.h"
#import "VIPConsultingViewController.h"
#import "UserSessionCenter.h"
#import "KeyBoardObserver.h"
///pay
#import "WXApi.h"

@interface VIPPaymentViewController ()<UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate> {
    NSArray *vipDurationList,*vipLevelsList;
    NSInteger selectedLevel,selectedDuration,pickerSelectedRow;
    NSString *tradeNo,*tradePrice;
}
@property (nonatomic, strong) UIView *tapView;

@end

@implementation VIPPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"立即购买";
    [self customBackButton];
    
    NSMutableArray *months = [NSMutableArray array];
    for (NSInteger i = 0; i<24; i++) {
        [months addObject:[NSString stringWithFormat:@"%ld个月",(long)(i+1)]];
    }
    vipDurationList = [NSArray arrayWithArray:months];
    selectedDuration = vipDurationList.count-1;
    selectedLevel = 0;
    
    btnWechat.selected = YES;//默认选中一个
    
    [self getVipDesc];
    [self getVipLevels];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatPayResultRespond:) name:Notification_WechatPay_Result_Notification object:nil];
    
    //用于输入的时候，点击空白返回
    self.tapView = [[UIView alloc] initWithFrame:self.view.bounds];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    self.tapView.userInteractionEnabled = YES;
    [self.tapView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weakSelf_(weakSelf);
    //添加键盘监听
    [KeyBoard keyboardWillShow:^(CGFloat keyboardHeight) {
        CGRect rect = weakSelf.view.frame;
        rect.origin.y = -keyboardHeight + 64+165;
        weakSelf.view.frame = rect;
        [self.tapView removeFromSuperview];
        [self.view addSubview:self.tapView];
    }];
    
    [KeyBoard keyboardWillHide:^(CGFloat keyboardHeight) {
        CGRect rect = weakSelf.view.frame;
        rect.origin.y = 64;
        weakSelf.view.frame = rect;
        [self.tapView removeFromSuperview];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //删除键盘监听
    [KeyBoard removeObserver];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_WechatPay_Result_Notification object:nil];
}

#pragma mark - Private
- (void)setPickerHidden:(bool)isHidden {
    maskView.hidden = isHidden;
    pickerPannel.hidden = isHidden;
}

- (void)getVipDesc {
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getVIPIntroList.action" param:nil onCompletion:^(id jsonResponse) {
        NSArray *arr = [jsonResponse objectForKey:@"rows"];
        if (isValidArray(arr)) {
            NSDictionary *dic = [arr firstObject];
            if (isValidDictionary(dic)) {
                [wView loadHTMLString:OptimizeHtmlString([dic objectForKey:@"content"]) baseURL:nil];
                return;
            }
        }
        [wView loadHTMLString:@"暂无简介~" baseURL:nil];
    } onError:^(NSError *error) {
        [wView loadHTMLString:@"暂无简介~" baseURL:nil];
    } defaultErrorAlert:NO isCacheNeeded:NO method:nil];
}

- (void)getVipLevels {
    //    [SVProgressHUD showWithStatus:String_Loading];
    //    [[AppsNetWorkEngine shareEngine] submitRequest:@"getVIPBuyCfgList.action" param:nil onCompletion:^(id jsonResponse) {
    //        [SVProgressHUD dismiss];
    //        vipLevelsList = [jsonResponse objectForKey:@"rows"];
    //        if (isValidArray(vipLevelsList)) {
    //            NSDictionary *dic = [vipLevelsList firstObject];
    //            labelName.text = [dic objectForKey:@"vip_name"];
    //            [self refreshPrice];
    //        }
    //        else {
    //            [wView loadHTMLString:@"暂无数据~" baseURL:nil];
    //        }
    //    } onError:^(NSError *error) {
    //        [SVProgressHUD dismiss];
    //    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    vipLevelsList = @[@{@"vip_name":@"金卡",@"vip_id":@"2"}];
    labelName.text = @"金卡";
    labelTime.text = [vipDurationList objectAtIndex:selectedDuration];
}

//此方法废弃
- (void)refreshPrice {
    NSDictionary *dic = [vipLevelsList objectAtIndex:selectedLevel];
    NSArray *arr = @[@"six_month",@"one_year",@"two_year",@"three_year"];
    
    labelTime.text = [vipDurationList objectAtIndex:selectedDuration];
    labelPrice.text = [NSString stringWithFormat:@"￥%@",[dic objectForKey:[arr objectAtIndex:selectedDuration]]];
}

- (void)setPaymenViewHidden:(bool)isHidden {
    maskView.hidden = isHidden;
    viewPayment.hidden = isHidden;
}

- (void)resetPaymentButtons {
    btnAliPay.selected = NO;
    btnUnion.selected = NO;
    btnWechat.selected = NO;
}

#pragma mark - Button Action
- (void)tapGesture:(UITapGestureRecognizer *)sender {
    [priceTextField resignFirstResponder];
}

- (IBAction)btnAction:(UIButton*)sender {
    if (sender.tag == 100) {
        
        if ([priceTextField.text isEqualToString:@""] || !isFloat(priceTextField.text) || (isFloat(priceTextField.text) && [priceTextField.text floatValue] < 1)) {
            [self showAlertWithTitle:nil message:@"请输入价格(>=1)" cancelButton:String_Sure sureButton:nil];
            [priceTextField resignFirstResponder];
            return;
        }
        
        //立即购买
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [[UserSessionCenter shareSession] getUserId], @"user_id",
                                       @(selectedDuration+1), @"timelength",
                                       priceTextField.text, @"fee", nil];
        [params setObject:vipLevelsList[selectedLevel][@"vip_id"] forKey:@"vip_id"];
        
        [[AppsNetWorkEngine shareEngine] submitRequest:@"userPreBuyVIP.action" param:params onCompletion:^(id jsonResponse) {
            if ([jsonResponse objectForKey:@"consume_no"]) {
                tradeNo = [jsonResponse objectForKey:@"consume_no"];
                tradePrice = [jsonResponse objectForKey:@"consume_fee"];
                [self setPaymenViewHidden:NO];
            }
            else {
                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
            }
        } onError:^(NSError *error) {
            
        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
    else if (sender.tag == 101) {
        //购买留言
        VIPConsultingViewController *cVc = [[VIPConsultingViewController alloc] init];
        cVc.vipId = vipLevelsList[selectedLevel][@"vip_id"];
        [self.navigationController pushViewController:cVc animated:YES];
    }
    else if (sender.tag == 200) {
        //VIP级别
        labelPickerTitle.text = @"VIP级别";
        myPicker.tag = 0;
        [self setPickerHidden:NO];
        [myPicker reloadAllComponents];
        [myPicker selectRow:selectedLevel inComponent:0 animated:NO];
    }
    else if (sender.tag == 201) {
        //VIP时长
        labelPickerTitle.text = @"VIP时长";
        myPicker.tag = 1;
        [self setPickerHidden:NO];
        [myPicker reloadAllComponents];
        [myPicker selectRow:selectedDuration inComponent:0 animated:NO];
    }
    
}

- (IBAction)pickerPannelAction:(UIButton*)sender {
    if (sender.tag == 100) {
        //取消
        [self setPickerHidden:YES];
    }
    else if (sender.tag == 101) {
        //确定
        [self setPickerHidden:YES];
        
        if (myPicker.tag) {
            //时长
            selectedDuration = pickerSelectedRow;
        }
        else {
            //级别
            selectedLevel = pickerSelectedRow;
        }
        labelTime.text = [vipDurationList objectAtIndex:selectedDuration];
        labelName.text = [vipLevelsList objectAtIndex:selectedLevel][@"vip_name"];
        
        //        [self refreshPrice];
    }
}

- (IBAction)paymentViewAction:(UIButton*)sender {
    if (sender.tag == 200) {
        //确定
        [self setPaymenViewHidden:YES];
        [self doPayment];
        return;
        //do payment
        [SVProgressHUD showSuccessWithStatus:@"购买成功"];
        NSDictionary *vipInfo = [vipLevelsList objectAtIndex:selectedLevel];
        [[UserSessionCenter shareSession] saveUserVipLevelId:[vipInfo objectForKey:@"vip_id"]];
        [[UserSessionCenter shareSession] saveUserVipLevelName:[vipInfo objectForKey:@"vip_name"]];
        [[UserSessionCenter shareSession] saveUserVipLevelDays:getString(@((selectedDuration+1)*6*30))];
    }
    else if (sender.tag == 201) {
        //支付宝
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 202) {
        //银联
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 203) {
        //微信
        [self resetPaymentButtons];
        sender.selected = YES;
    }
    else if (sender.tag == 210) {
        //关闭
        [self setPaymenViewHidden:YES];
    }
}


#pragma mark - UIPickerViewDelegate & DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return myPicker.tag ? vipDurationList.count : vipLevelsList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (myPicker.tag) {
        return [vipDurationList objectAtIndex:row];
    }
    else {
        NSDictionary *dic = [vipLevelsList objectAtIndex:row];
        return dic[@"vip_name"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    pickerSelectedRow = row;
    //    if (isDuration) {
    //        selectedDuration = row;
    //        labelTime.text = [vipDurationList objectAtIndex:row];
    //    }
    //    else {
    //        selectedLevel = row;
    //        NSDictionary *dic = [vipLevelsList objectAtIndex:row];
    //        labelName.text = [dic objectForKey:@"vip_name"];
    //    }
}

#pragma mark - Payment
- (void)doPayment {
    
    if (btnAliPay.selected) {
        [self payWithAli];
    }
    else if (btnUnion.selected) {
        [self payWithUnion];
    }
    else if (btnWechat.selected) {
        [SVProgressHUD showWithStatus:String_Loading];
        [self payWithWechat];
    }
}

- (void)payWithAli {
    [SVProgressHUD showSuccessWithStatus:@"即将开通!"];
}

- (void)payWithUnion {
    [SVProgressHUD showSuccessWithStatus:@"即将开通!"];
}

- (void)wechatPayResultRespond:(NSNotification*)aNotification {
    NSDictionary *vipInfo = [vipLevelsList objectAtIndex:selectedLevel];
    
    PayResp *resp = (PayResp*)aNotification.object;
    switch (resp.errCode) {
        case WXSuccess:
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [SVProgressHUD showSuccessWithStatus:@"支付成功!"];
            
            [[UserSessionCenter shareSession] saveUserVipLevelId:[vipInfo objectForKey:@"vip_id"]];
            [[UserSessionCenter shareSession] saveUserVipLevelDays:[NSString stringWithFormat:@"%@",@((selectedDuration+1)*60)]];
            [app_delegate() loginOnBackground:nil password:nil];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.f];
            break;
            
        default:
            
            break;
    }
}


#pragma mark - For Wechat
- (void)payWithWechat {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tradeNo,@"consume_no", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"buildWechatPaySerialNo.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        if (isValidString([jsonResponse objectForKey:@"serial_no"])) {
            //获取PrePayId成功，跳过去支付
            NSString *timeStamp = [jsonResponse objectForKey:@"timestamp"];//[self genTimeStamp];//
            
            //构造支付请求
            PayReq *request = [[PayReq alloc]init];
            //服务器签名
            request.openID = [jsonResponse objectForKey:@"appid"];
            request.partnerId = [jsonResponse objectForKey:@"partnerid"];
            request.prepayId = [jsonResponse objectForKey:@"prepayid"];
            request.package = [jsonResponse objectForKey:@"package"];
            request.nonceStr = [jsonResponse objectForKey:@"noncestr"];
            request.timeStamp = (UInt32)[timeStamp longLongValue];
            request.sign = [jsonResponse objectForKey:@"sign"];
            
            [WXApi sendReq:request];
        }
        else {
            [self showAlertWithTitle:nil message:@"获取订单信息失败，请重试!" cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

@end
