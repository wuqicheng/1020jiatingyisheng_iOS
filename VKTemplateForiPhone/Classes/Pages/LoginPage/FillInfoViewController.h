//
//  FillInfoViewController.h
//  VKTemplateForiPhone
//
//  Created by Vescky on 15/2/13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FillInfoViewController : AppsBaseViewController {
    IBOutlet UILabel *labelBirthday,*labelAddress,*labelTips;
    IBOutlet UITableViewCell *cell1,*cell2,*cell3,*cell4,*cell5,*cell6,*cell7,*cell8,*cell9;
    IBOutlet UIImageView *imgAvatar;
    IBOutlet UIButton *checkboxMale,*checkboxFemale,*btnSure;
    IBOutlet UITableView *tbView;
    IBOutlet UIScrollView *scView;
    IBOutlet UITextField *tfUserNick,*tfWechatNo,*tfEmail,*tfName,*tfPhoneNum;
}

@property bool isRegister;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) NSString *psw;

- (IBAction)btnAction:(UIButton*)sender;

@end
