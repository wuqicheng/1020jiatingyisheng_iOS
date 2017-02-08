//
//  PhoneCallViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by NPHD on 15/7/30.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface PhoneCallViewController : AppsBaseViewController
{
    IBOutlet UIScrollView *scView;
    IBOutlet UILabel *menuLabel,*starTime,*apointmentTime,*endTime,*nickName,*payLable;
    IBOutlet UIImageView *imageAvtar;

}
- (IBAction)btnAction:(UIButton*)sender;
@property(nonatomic,strong) NSString *phoneCallId;
@property (nonatomic,strong) NSString *phone;
@end
