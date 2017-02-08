//
//  FollowUpListViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface FollowUpListViewController : AppsBaseTableViewController {
    IBOutlet UILabel *labelNoData;
    
    IBOutlet UIButton *btnButtom;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
