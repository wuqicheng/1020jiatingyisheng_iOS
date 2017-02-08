//
//  HeathyProjectViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeathyProjectViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UITableViewCell *cell1,*cell2,*cell3,*cell4,*cell5,*cell6;
    IBOutlet UITableViewCell *cell7;
    IBOutlet UILabel *labelDate,*labelWeek;
    IBOutlet UILabel *labelPercentage1,*labelPercentage2,*labelPercentage3,*labelPercentage4;
    IBOutlet UIButton *btnPrevious,*btnNext;
    IBOutlet UIButton *btnButtom;
}

- (IBAction)commit:(UIButton *)sender;
- (IBAction)btnAction:(UIButton*)sender;
- (IBAction)alertButton:(UIButton*)sender;
- (IBAction)btn:(UIButton*)sender;

@end
