//
//  TodayClinicViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface TodayClinicViewController : AppsBaseTableViewController {
    IBOutlet UILabel *labelTitle,*labelTime;
    IBOutlet UIWebView *wView;
    IBOutlet UITableViewCell *cell1;
}

@property (nonatomic,strong) NSDictionary *detailInfo;

@end
