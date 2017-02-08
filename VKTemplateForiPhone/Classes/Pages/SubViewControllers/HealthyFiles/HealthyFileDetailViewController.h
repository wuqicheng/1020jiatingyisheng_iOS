//
//  HealthyFileDetailViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthyFileDetailViewController : AppsBaseViewController {
    IBOutlet UILabel *labelTitle,*labelTime;
    IBOutlet UIWebView *wView;
    IBOutlet UIView *viewForTime;
    IBOutlet UIScrollView *scView;
}

@property (nonatomic,assign) bool isReport;
@property (nonatomic,strong) NSDictionary *detailInfo;

@end
