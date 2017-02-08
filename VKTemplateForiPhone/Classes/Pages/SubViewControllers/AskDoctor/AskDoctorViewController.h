//
//  AskDoctorViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface AskDoctorViewController : AppsBaseTableViewController {
    IBOutlet UIView *viewPannel,*maskView;
    IBOutlet UITableView *tbMenu;
    IBOutlet UIButton *btn1Text,*btn1Icon,*btn2Text,*btn2Icon;
    IBOutlet UILabel *labelNoData,*label1,*label2;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
