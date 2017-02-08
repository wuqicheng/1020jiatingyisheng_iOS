//
//  SelfAssessmentVC.h
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/30.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface SelfAssessmentVC : AppsBaseViewController{
    IBOutlet UIButton *btn;
     IBOutlet UILabel *labelDate;
     IBOutlet UILabel *labelWeek;
    IBOutlet UIButton *btnPrevious;
    IBOutlet UIButton *btnNext;
}

- (IBAction)btnAction:(UIButton*)sender;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, assign) NSInteger selectIndex;

- (IBAction)btnAction1:(UIButton*)sender;
- (IBAction)alertButton:(UIButton*)sender;

@end
