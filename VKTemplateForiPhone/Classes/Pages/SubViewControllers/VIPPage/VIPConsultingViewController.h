//
//  VIPConsultingViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIPConsultingViewController : AppsBaseViewController {
    IBOutlet UITextField *tfName,*tfPhone;
    IBOutlet UITextView *tvContent;
    IBOutlet UILabel *labelPlaceHolder,*labelTips;
    IBOutlet UIScrollView *scView;
}

@property (nonatomic,strong) NSString *vipId;
@property int duration;

@end
