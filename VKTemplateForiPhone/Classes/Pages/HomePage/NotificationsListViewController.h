//
//  NotificationsListViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface NotificationsListViewController : AppsBaseTableViewController {
    IBOutlet UILabel *labelNoData;
}
@property (nonatomic, strong) NSMutableArray *messagelist;
@end
