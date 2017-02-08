//
//  NotificationDetailViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationDetailViewController : AppsBaseViewController {
    IBOutlet UIWebView *wView;
}

@property (nonatomic,strong) NSDictionary *detailInfo;

@end
