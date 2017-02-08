//
//  DoctorDetailViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface DoctorDetailViewController : AppsBaseTableViewController {
    IBOutlet UILabel *labelDoctorName,*labelCost,*labelNoData,*labelDesc,*labelCallCost,*phoneTitle;
    IBOutlet UIView *viewFace,*viewPayment,*viewMask;
    IBOutlet UIButton *btnIsOnline, *phoneStatus;
    IBOutlet UIButton *btnAliPay;
    IBOutlet UIButton *btnWechat;
    IBOutlet UIButton *btnUnion;
    IBOutlet UIImageView *imgvAvatar;
}

@property (nonatomic,strong) NSDictionary *detailInfo;
@property (nonatomic,strong) NSString *phone;

- (IBAction)btnAction:(UIButton*)sender;
- (IBAction)paymentViewAction:(UIButton*)sender;

@end
