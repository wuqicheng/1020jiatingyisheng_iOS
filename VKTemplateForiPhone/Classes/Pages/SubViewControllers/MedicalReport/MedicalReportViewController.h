//
//  MedicalReportViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface MedicalReportViewController : AppsBaseTableViewController {
    IBOutlet UIButton *btn1,*btn2,*btnButtom;
    IBOutlet UIView *cursor1,*cursor2;
    IBOutlet UILabel *labelNoData;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
