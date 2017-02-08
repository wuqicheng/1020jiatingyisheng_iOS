//
//  UserCenterViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/2/8.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCenterViewController : AppsBaseViewController {
    IBOutlet UITableViewCell *cell1,*cell2,*cell3,*cell4,*cell5,*cell6,*cell7,*cell8,*cell9,*cell10,*cell11;
    IBOutlet UITableViewCell *cell12;
    IBOutlet UILabel *labelUserName,*labelLeftTime;
    IBOutlet UITableView *tbView;
    IBOutlet UIImageView *imgvAvatar;
    IBOutlet UIButton *btnVIP,*btnCheck;
    IBOutlet UIView *titleView;
    IBOutlet UIButton *logout;
    
}

- (IBAction)btnAction:(UIButton*)sender;

@end
