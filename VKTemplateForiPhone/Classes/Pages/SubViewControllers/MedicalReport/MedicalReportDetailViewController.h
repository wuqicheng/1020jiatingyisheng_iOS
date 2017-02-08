//
//  MedicalReportDetailViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicalReportDetailViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle,*labelTime;
    IBOutlet UIWebView *wView;
    IBOutlet UIView *viewForTime,*titleView;
    IBOutlet UIScrollView *scView;
}

@property (nonatomic,strong) NSDictionary *detailInfo;
@property (nonatomic,assign) bool isReport;

@end
