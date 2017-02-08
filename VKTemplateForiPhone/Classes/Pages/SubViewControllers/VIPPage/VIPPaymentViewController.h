//
//  VIPPaymentViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIPPaymentViewController : AppsBaseViewController {
    IBOutlet UIWebView *wView;
    IBOutlet UILabel *labelName,*labelTime,*labelPrice;
    IBOutlet UIView *pickerPannel,*maskView,*viewPayment;
    IBOutlet UILabel *labelPickerTitle;
    IBOutlet UIPickerView *myPicker;
    IBOutlet UIButton *btnAliPay;
    IBOutlet UIButton *btnUnion;
    IBOutlet UIButton *btnWechat;
    IBOutlet UITextField *priceTextField;
}

- (IBAction)btnAction:(UIButton*)sender;

- (IBAction)pickerPannelAction:(UIButton*)sender;

- (IBAction)paymentViewAction:(UIButton*)sender;

@end
