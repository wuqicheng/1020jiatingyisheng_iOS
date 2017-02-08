//
//  ChatBoxViewController.h
//  VKTemplateForiPhone
//
//  Created by NPHD on 15/7/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"
#import "AppsBaseTableViewController.h"
@interface ChatBoxViewController : AppsBaseTableViewController
{
    IBOutlet UIButton *btn1,*btn2;
    IBOutlet UIView *view1,*view2;
    IBOutlet UILabel *labelNoData;
}
- (IBAction)btnAction:(UIButton*)sender;
@end
