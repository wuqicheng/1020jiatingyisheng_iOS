//
//  DoctorCalanderViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoctorCalanderViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UILabel *labelMonth,*labelTime;
    IBOutlet UITableViewCell *cell1,*cell2,*cellCalendar;
}

@property (nonatomic,strong) NSDictionary *doctorInfo;

- (IBAction)btnAction:(UIButton*)sender;

@end
