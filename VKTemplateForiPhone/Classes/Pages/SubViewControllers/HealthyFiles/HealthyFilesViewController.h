//
//  HealthyFilesViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/4/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthyFilesViewController : AppsBaseViewController {
    IBOutlet UILabel *labelName,*labelTime;
    IBOutlet UIImageView *imgvAvatar;
    IBOutlet UITableView *tbView;
    IBOutlet UITableViewCell *cell1,*cell2,*cell3;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
