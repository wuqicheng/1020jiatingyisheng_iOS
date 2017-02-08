//
//  FamousDoctorSearch_VC.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/24.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamousDoctorViewController.h"
@interface FamousDoctorSearch_VC : AppsBaseTableViewController
@property (nonatomic, strong) NSString *searchStr;
@property (weak, nonatomic) IBOutlet UIView *notFoundDataView;

@end
