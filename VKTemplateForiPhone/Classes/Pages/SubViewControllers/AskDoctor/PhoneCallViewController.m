//
//  PhoneCallViewController.m
//  jiankangshouhuzhuanjia
//
//  Created by NPHD on 15/7/30.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "PhoneCallViewController.h"
#import "UserSessionCenter.h"
#import "UIImageView+MJWebCache.h"
@interface PhoneCallViewController ()

@end

@implementation PhoneCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customBackButton];
    self.title = @"电话咨询";
    [scView setContentSize:CGSizeMake(scView.frame.size.width, scView.frame.size.height+100)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPhoneCallMenuData];
}

//打电话
- (IBAction)btnAction:(UIButton*)sender
{
    if (sender.tag == 100) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:0516-82181020"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
        
//        if (self.phone.length > 0) {
//            //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[cInfo objectForKey:@"phone"]]]];
//            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.phone];
//            UIWebView * callWebview = [[UIWebView alloc] init];
//            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//            [self.view addSubview:callWebview];
//        }
//        else {
//            [SVProgressHUD showErrorWithStatus:@"服务热线尚未开通"];
//        }

//        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//            _phoneCallId,@"phone_conversation_id",app_delegate().sessionId,@"sessionid",nil];
//        [[AppsNetWorkEngine shareEngine] submitRequest:@"callPhoneByUser.action" param:params onCompletion:^(id jsonResponse) {
//            [SVProgressHUD dismiss];
//            
//            if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
//                
//                [self showAlertWithTitle:nil message:@"电话咨询请求成功，请耐心等待拨入电话！" cancelButton:String_Sure sureButton:nil];
//
//            }
//            else {
//                [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
//            }
//        } onError:^(NSError *error) {
//            [SVProgressHUD dismiss];
//        } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
    }
   
}
#pragma loading
//获取电话订单数据
-(void)loadPhoneCallMenuData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [[UserSessionCenter shareSession] getUserId],@"user_id",app_delegate().sessionId,@"sessionid",_phoneCallId,@"phone_conversation_id",nil];
    NSLog(@"%@",app_delegate().sessionId);
    NSLog(@"%@`````",params);
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getPhoneCommnetSessionListByUser.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];

        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            NSArray *dic = [jsonResponse objectForKey:@"rows"];
            for (int i = 0; i<dic.count; i++) {
                menuLabel.text = [[dic objectAtIndex:i] objectForKey:@"consume_no"];
                if (isValidString(getString([[dic objectAtIndex:i] objectForKey:@"doctor_cfg_time"]))) {
                    apointmentTime.text = getString([[dic objectAtIndex:i] objectForKey:@"doctor_cfg_time"]);
                }
                if (isValidString([[dic objectAtIndex:i] objectForKey:@"phone_start_time"])) {
                     starTime.text = [[dic objectAtIndex:i] objectForKey:@"phone_start_time"];
                }
               
                endTime.text = [NSString stringWithFormat:@"%@分钟",[[dic objectAtIndex:i] objectForKey:@"remain_time"]];
                nickName.text = [[dic objectAtIndex:i] objectForKey:@"user_name"];
                payLable.text = [[dic objectAtIndex:i] objectForKey:@"pay_time"];
                [imageAvtar setImageURLStr:[[dic objectAtIndex:i] objectForKey:@"photo"] placeholder:Defualt_Avatar_Image];
                imageAvtar.layer.cornerRadius = imageAvtar.frame.size.width / 2.f;
            }
            
        }
        else {
            [self showAlertWithTitle:nil message:[jsonResponse objectForKey:@"desc"] cancelButton:String_Sure sureButton:nil];
        }
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}


@end
