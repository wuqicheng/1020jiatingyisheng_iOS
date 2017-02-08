//
//  EvaluateDoctorViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsRatingView.h"

@interface EvaluateDoctorViewController : AppsBaseViewController {
    IBOutlet UITextView *tvContent;
    IBOutlet StarsRatingView *rateView1,*rateView2;
    IBOutlet UILabel *labelPlaceHolder;
}

//@property (nonatomic,strong) NSDictionary *detailInfo;
@property (nonatomic,strong) NSString *conversationId;
@property(nonatomic,strong) NSString *phoneCallId;
- (IBAction)btnAction:(UIButton*)sender;

@end
